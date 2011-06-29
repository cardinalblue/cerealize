# encoding: utf-8

require 'cerealize/attr_hash'

gem 'activerecord'
require 'active_record'
autoload :YAML, 'yaml'

module Cerealize
  InternalName = 'CerealizeMethods'

  module Codec
    autoload 'Yaml'   , 'cerealize/codec/yaml'
    autoload 'Marshal', 'cerealize/codec/marshal'
    autoload 'Text'   , 'cerealize/codec/text'
  end
  class NoSuchCodec     < ArgumentError; end
  class NoSuitableCodec < RuntimeError ; end

  #
  # Dirty functionality: note that *_changed? and changed? work,
  # but *_was, *_change, and changes do NOT work.
  #

  def self.included(base)
    base.send( :extend,    ClassMethods)
    base.send(:include, InstanceMethods)
    base.superclass_delegating_accessor :cerealize_option
    base.cerealize_option = {}
  end

  module_function
  def codecs
    @codecs ||= codec_names.map{ |codec_name|
                  codec_get(codec_name)
                }
  end

  def codec_names
    @codec_names ||= [:yaml, :marshal, :text]
  end

  def codec_detect(str)
    codecs.find{ |codec| codec.yours?(str) }
  end

  def codec_get(codec_name)
    Codec.const_get(codec_name.to_s.capitalize)
  rescue NameError
    raise NoSuchCodec.new(codec_name)
  end

  def encode(obj, codec)
    return nil unless obj
    codec.encode(obj)
  end

  def decode(str, codec=nil)
    return nil unless str
    codec ||= codec_detect(str)

    if codec && codec.yours?(str)
      codec.decode(str)
    else
      raise NoSuitableCodec.new("#{str[0..46]}...")
    end
  end

  module InstanceMethods
    def cerealize_decode property, value
      opt = self.class.cerealize_option[property]
      Cerealize.decode( value, opt[:force_encoding] && opt[:codec] )
    end

    def cerealize_encode property, value
      opt = self.class.cerealize_option[property]
      Cerealize.encode( value, opt[:codec] )
    end
  end

  module ClassMethods
    def cerealize_update_codec_cache
      cerealize_option.each{ |(property, opt)|
        opt.merge!(:codec => Cerealize.codec_get(opt[:encoding]))
      }
    end

    def cerealize property, klass=nil, opt={}
      opt[:encoding] ||= :marshal
      cerealize_option[property] =
        opt.merge(:class => klass,
                  :codec => Cerealize.codec_get(opt[:encoding]))

      field_orig  = "#{property}_orig"
      field_cache = "#{property}_cache"

      attr_accessor field_orig
      private field_orig, "#{field_orig}="

      mod = if const_defined?(Cerealize::InternalName)
              const_get(Cerealize::InternalName)
            else
              const_set(Cerealize::InternalName, Module.new)
            end

      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{field_cache}
          @#{property}
        end

        def #{field_cache}=(new_value)
          @#{property} = new_value
        end
      RUBY

      # Invariants:
      #   - instance_variable_defined?(field_cache)  IFF the READER or WRITER has been called
      #   - instance_variable_defined?(field_pre)    IFF the READER was called BEFORE
      #                                              any WRITER

      # READER method
      #
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{property}
          # Return cached
          return #{field_cache} if #{field_cache}

          # No assignment yet, save property if not already saved
          self.#{field_orig}= self[:#{property}] if !#{field_orig}

          # Set cached from pre
          value = cerealize_decode(:#{property}, #{field_orig})

          raise ActiveRecord::SerializationTypeMismatch, "expected #{klass}, got \#{value.class}" \\
            if #{klass.inspect} && !value.nil? && !value.kind_of?(#{klass})

          self.#{field_cache} = value
        end
      RUBY

      # WRITER method
      #
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{property}=(value)
          #{property}_will_change! if #{field_cache} != value
          self.#{field_cache} = value
        end
      RUBY

      # Callback for before_save
      #
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{property}_update_if_dirty
          # See if we have a new cur value
          if instance_variable_defined?('@#{property}')
            value     = #{field_cache}
            value_enc = cerealize_encode(:#{property}, value)

            # See if no orig at all (i.e. it was written to before
            # being read), or if different. When comparing, compare
            # both marshalized string, and Object ==.
            #
            if !#{field_orig} ||
              (value_enc != #{field_orig} &&
               value     != cerealize_decode(:#{property}, #{field_orig}))
              self[:#{property}] = value_enc
            end

            remove_instance_variable('@#{property}')
          end

          self.#{field_orig} = nil
        end
      RUBY

      include mod unless self < mod
      before_save("#{property}_update_if_dirty")
    end
  end
end # of Cerealize
