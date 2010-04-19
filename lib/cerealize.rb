# encoding: utf-8

require 'active_record'
autoload :YAML, 'yaml'

module Cerealize
  module Codec
    autoload 'Yaml',    'cerealize/codec/yaml'
    autoload 'Marshal', 'cerealize/codec/marshal'
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
  end

  module_function
  def codecs
    @codecs ||= codec_names.map{ |codec_name|
                  codec_get(codec_name)
                }
  end

  def codec_names
    @codec_names ||= [:yaml, :marshal]
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
    def cerealize_option
      @cerealize_option ||= {}
    end

    def cerealize property, klass=nil, opt={}
      opt[:encoding] ||= :marshal
      cerealize_option[property] =
        opt.merge(:class => klass,
                  :codec => Cerealize.codec_get(opt[:encoding]))

      field_pre   = "@#{property}_pre".to_sym
      field_cache = "@#{property}".to_sym

      # Invariants:
      #   - instance_variable_defined?(field_cache)  IFF the READER or WRITER has been called
      #   - instance_variable_defined?(field_pre)    IFF the READER was called BEFORE
      #                                              any WRITER

      # READER method
      #
      define_method property do
        # Rails.logger.debug "#{property} (READER)"

        # See if no assignment yet
        if !instance_variable_defined?(field_cache)

          # Save property if not already saved
          if !instance_variable_defined?(field_pre)
            instance_variable_set(field_pre, read_attribute(property))
          end

          # Set cached from pre
          v = cerealize_decode(property, instance_variable_get(field_pre))
          raise ActiveRecord::SerializationTypeMismatch, "expected #{klass}, got #{v.class}" \
            if klass && !v.nil? && !v.kind_of?(klass)
          instance_variable_set(field_cache, v)
        end

        # Return cached
        instance_variable_get(field_cache)
      end

      # WRITER method
      #
      define_method "#{property}=" do |v|
        # Rails.logger.debug "#{property}=#{v}"
        send "#{property}_will_change!" if instance_variable_get(field_cache) != v
        instance_variable_set(field_cache, v)
      end

      # Callback for before_save
      #
      define_method "#{property}_update_if_dirty" do
        # Rails.logger.debug "#{property}_update_if_dirty"

        # See if we have a new cur value
        if instance_variable_defined?(field_cache)
          v = instance_variable_get(field_cache)
          v_enc = cerealize_encode(property, v)

          # See if no pre at all (i.e. it was written to before being read),
          # or if different. When comparing, compare both marshalized string,
          # and Object ==.
          #
          if !instance_variable_defined?(field_pre) ||
            (v_enc != instance_variable_get(field_pre) &&
                 v != cerealize_decode(property, instance_variable_get(field_pre)))
            write_attribute(property, v_enc)
          end
        end
        remove_instance_variable(field_pre)   if instance_variable_defined?(field_pre)
        remove_instance_variable(field_cache) if instance_variable_defined?(field_cache)
      end
      before_save("#{property}_update_if_dirty")
    end
  end
end # of Cerealize
