# encoding: utf-8

require 'active_record'
autoload :YAML, 'yaml'

module Cerealize

  #
  # Dirty functionality: note that *_changed? and changed? work,
  # but *_was, *_change, and changes do NOT work.
  #

  def self.included(base)
    base.send :extend, ClassMethods
  end

  def self.marshal_to(obj)
    obj && ActiveSupport::Base64.encode64(Marshal.dump(obj))
  end
  def self.marshal_from(s)
    s && Marshal.load(ActiveSupport::Base64.decode64(s))
  end
  def self.yaml_to(obj)
    obj && obj.to_yaml
  end
  def self.yaml_from(s)
    obj && YAML.load(obj)
  end

  def self.encode(obj, encoding)
    case encoding
    when :marshal;  marshal_to(obj)
    when :yaml;     yaml_to(obj)
    else            raise "invalid encoding #{encoding}"
    end
  end
  def self.decode(s)
    if s.nil?;                nil
    elsif s[0..2] == '---';   YAML.load(s)    # See YAML spec (though might fail if "directives"?)
    elsif s[0..1] == 'BA';    marshal_from(s) # Version 4.8 of Marshalize always base64s to "BA"
    else                      raise "Unknown field format for '#{s}'"
    end
  end

  module ClassMethods

    def cerealize property, klass=nil, options={}
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
          v = Cerealize.decode(instance_variable_get(field_pre))
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
          v_enc = Cerealize.encode(v, options[:encoding] || :marshal)

          # See if no pre at all (i.e. it was written to before being read),
          # or if different. When comparing, compare both marshalized string,
          # and Object ==.
          #
          if !instance_variable_defined?(field_pre) ||
            (v_enc != instance_variable_get(field_pre) &&
              v != Cerealize.decode(instance_variable_get(field_pre)))
            write_attribute(property, v_enc)
          end
        end
        remove_instance_variable(field_pre)   if instance_variable_defined?(field_pre)
        remove_instance_variable(field_cache) if instance_variable_defined?(field_cache)
      end
      before_save("#{property}_update_if_dirty")
    end
  end
end

