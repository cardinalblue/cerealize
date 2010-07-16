# encoding: utf-8

unless respond_to?(:require_relative, true)
  def require_relative path
    require "#{File.dirname(__FILE__)}/#{path}"
  end
end

require_relative 'common'

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

  def test_no_suitable_codec_if_force_encoding
    cat = Cat.new
    cat[:tail] = '---'
    cat.save
    id = cat.id
    assert_raise Cerealize::NoSuitableCodec do
      Cat.find(id).tail
    end
  end

  def test_auto_transcode_yaml
    name = 'Nine Tails'
    marshaled_name = Cerealize::Codec::Marshal.encode(name)
    cat = Cat.new
    cat[:name] = marshaled_name
    cat.save
    id = cat.id

    new_cat = Cat.find(id)
    assert_equal name, new_cat.name
    new_cat.name.reverse!

    # no change if not saved yet
    assert_equal marshaled_name, new_cat[:name]
    new_cat.save

    # should be transcode into YAML
    assert Cerealize::Codec::Yaml.yours?(new_cat[:name])
    new_cat.reload
    assert Cerealize::Codec::Yaml.yours?(new_cat[:name])
  end

  def test_auto_transcode_marshal
    food = {:a => :b}
    yamled_food = Cerealize::Codec::Yaml.encode(food)
    cat = Cat.new
    cat[:food] = yamled_food
    cat.save
    cat.reload

    assert_equal food, cat.food
    assert_equal yamled_food, cat[:food]
    cat.food.merge!(:c => :d)
    cat.save
    cat.reload

    assert Cerealize::Codec::Marshal.yours?(cat[:food])
    assert_equal food.merge(:c => :d), cat.food
  end
end
