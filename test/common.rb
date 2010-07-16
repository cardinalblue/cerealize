# encoding: utf-8

require 'rubygems' if RUBY_VERSION < '1.9.1'
require 'cerealize'

require_relative 'stub'
require_relative 'real'

require 'test/unit'

def set_encoding(encoding)
  Boat.cerealize_option[:captain] = {:class    => nil,
                                     :encoding => encoding}
  Boat.cerealize_update_codec_cache
end
