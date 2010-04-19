# encoding: utf-8

def set_encoding(encoding)
  Boat.cerealize_option[:captain] = {:class    => nil,
                                     :encoding => encoding}
  Boat.cerealize_update_codec_cache
end
