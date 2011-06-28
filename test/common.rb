# encoding: utf-8

require 'cerealize'

require 'bacon'

require_relative 'stub'
require_relative 'real'

Bacon.summary_on_exit

def set_encoding(encoding)
  Boat.cerealize_option[:captain] = {:class    => nil,
                                     :encoding => encoding}
  Boat.cerealize_update_codec_cache
end
