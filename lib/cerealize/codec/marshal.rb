
module Cerealize
  module Codec; end
  module Codec::Marshal
    module_function

    # Version 4.8 of Marshalize always base64s to "BA"
    # TODO: extract base64 decorator, then we can use pure marshal
    def yours?(str)
      str[0..1] == 'BA'
    end

    def encode(obj)
      [Marshal.dump(obj)].pack('m*')
    end

    def decode(str)
      Marshal.load(str.unpack('m*').first)
    end
  end
end
