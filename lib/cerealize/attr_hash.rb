
module Cerealize
  module AttrHash
    InternalName = 'AttrHashMethods'

    def self.included mod
      mod.send(:extend, ClassMethods)
    end

    module ClassMethods
      def attr_hash property, *attrs
        ruby = attrs.inject([]){ |codes, attr|
          codes << <<-RUBY
            def #{attr}
              if #{property}
                #{property}[:#{attr}]
              else
                nil
              end
            end

            def #{attr}= value
              self.#{property} ||= {}
              #{property}[:#{attr}] = value
            end
          RUBY
        }.join("\n")

        mod = if const_defined?(Cerealize::AttrHash::InternalName)
                const_get(Cerealize::AttrHash::InternalName)
              else
                const_set(Cerealize::AttrHash::InternalName, Module.new)
              end

        mod.module_eval ruby
        include mod unless self < mod
      end
    end
  end
end
