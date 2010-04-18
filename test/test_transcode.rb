# encoding: utf-8

require 'rubygems' if RUBY_VERSION < '1.9.1'
require 'cerealize'

require 'test/stub'
require 'test/helper'
require 'test/helper_active_record'

require 'test/unit'

class TranscodeTest < Test::Unit::TestCase
  def setup
    Cat.delete_all
  end

  def teardown
  end

  def test_no_such_codec
    assert_raise Cerealize::NoSuchCodec do
      Cat.dup.send(:cerealize, :bad, Hash, :encoding => :blah)
    end
  end

  def test_no_suitable_codec
    cat = Cat.new
    cat[:tail] = '---'
    cat.save
    id = cat.id
    assert_raise Cerealize::NoSuitableCodec do
      Cat.find(id).tail
    end
  end

  def test_auto_transcode
    name = 'Nine Tails'
    marshaled_name = Cerealize::Codec::Marshal.encode(name)
    cat = Cat.new
    cat[:name] = marshaled_name
    cat.save
    id = cat.id

    new_cat = Cat.find(id)
    assert_equal name, new_cat.name
    new_cat.name.reverse!

    assert_equal marshaled_name, new_cat[:name]
    new_cat.save

    assert Cerealize::Codec::Yaml.yours?(new_cat[:name])
  end
end
