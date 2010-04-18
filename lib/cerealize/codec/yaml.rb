
module Cerealize
  module Codec; end
  module Codec::Yaml
    module_function

    # See YAML spec (though might fail if "directives"?)
    def yours?(str)
      str[0..2] == '---'
    end

    def encode(obj)
      YAML.dump(obj)
    end

    def decode(str)
      YAML.load(str)
    end
  end
end
