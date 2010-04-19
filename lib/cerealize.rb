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

      field_orig  = "#{property}_pre"
      field_cache = "#{property}_cache"

      attr_accessor field_orig
      private field_orig, "#{field_orig}="

      define_method field_cache do
        instance_variable_get("@#{property}")
      end

      define_method "#{field_cache}=" do |v|
        instance_variable_set("@#{property}", v)
      end

      # Invariants:
      #   - instance_variable_defined?(field_cache)  IFF the READER or WRITER has been called
      #   - instance_variable_defined?(field_pre)    IFF the READER was called BEFORE
      #                                              any WRITER

      # READER method
      #
      define_method property do
        # Rails.logger.debug "#{property} (READER)"

        # See if no assignment yet
        if !send(field_cache)

          # Save property if not already saved
          if !send(field_orig)
            send("#{field_orig}=", self[property])
          end

          # Set cached from pre
          v = cerealize_decode(property, send(field_orig))
          raise ActiveRecord::SerializationTypeMismatch, "expected #{klass}, got #{v.class}" \
            if klass && !v.nil? && !v.kind_of?(klass)
          send("#{field_cache}=", v)
        end

        # Return cached
        send(field_cache)
      end

      # WRITER method
      #
      define_method "#{property}=" do |v|
        # Rails.logger.debug "#{property}=#{v}"
        send "#{property}_will_change!" if send(field_cache) != v
        send("#{field_cache}=", v)
      end

      # Callback for before_save
      #
      define_method "#{property}_update_if_dirty" do
        # Rails.logger.debug "#{property}_update_if_dirty"

        # See if we have a new cur value
        if send(field_cache)
          v = send(field_cache)
          v_enc = cerealize_encode(property, v)

          # See if no pre at all (i.e. it was written to before being read),
          # or if different. When comparing, compare both marshalized string,
          # and Object ==.
          #
          if !send(field_orig) ||
            (v_enc != send(field_orig) &&
                 v != cerealize_decode(property, send(field_orig)))
            self[property] = v_enc
          end
        end
        send("#{field_orig}=",  nil)
        send("#{field_cache}=", nil)
      end
      before_save("#{property}_update_if_dirty")
    end
  end
end # of Cerealize
