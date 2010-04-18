# encoding: utf-8

def set_encoding(encoding)
  Boat.send :cerealize, :captain, nil, :encoding => encoding
end
