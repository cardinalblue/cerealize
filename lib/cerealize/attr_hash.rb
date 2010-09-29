
module Cerealize
  module ClassMethods
    def attr_hash property, attrs
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
            # this line fixes the quirks in ActiveRecord 2.3.9 at
            # activerecord-2.3.9/lib/active_record/associations/association_collection.rb:L352-L363
            # when we're using associations and STI, thanks Jaime
            # TODO: test for this?
            #{property}_will_change! if respond_to? :#{property}_will_change!

            self.#{property} ||= {}
            #{property}[:#{attr}] = value
          end
        RUBY
      }.join("\n")

      mod = if const_defined?(Cerealize::InternalName)
              const_get(Cerealize::InternalName)
            else
              const_set(Cerealize::InternalName, Module.new)
            end

      mod.module_eval ruby
      include mod unless self < mod
    end
  end
end
