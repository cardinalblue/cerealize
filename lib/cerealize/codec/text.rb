
module Cerealize
  module Codec; end
  module Codec::Text
    module_function

    def yours?(str)
      true
    end

    def encode(obj)
      YAML.dump(obj)
    end

    def decode(str)
      str
    end
  end
end
