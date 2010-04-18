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
    cat.write_attribute(:tail, '---')
    cat.save
    id = cat.id
    assert_raise Cerealize::NoSuitableCodec do
      Cat.find(id).tail
    end
  end
end
