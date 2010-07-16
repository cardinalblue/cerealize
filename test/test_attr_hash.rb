
require 'rubygems' if RUBY_VERSION < '1.9.1'
require 'cerealize'
require 'cerealize/attr_hash'

require 'test/stub'
require 'test/helper'
require 'test/helper_active_record'

require 'test/unit'

ActiveRecord::Base.connection.create_table :apples, :force => true do |t|
  t.text :attr_hash
end

class AttrHashTest < Test::Unit::TestCase
  class Apple < ActiveRecord::Base
    include Cerealize
    include Cerealize::AttrHash
    cerealize :attr_hash
    attr_hash :attr_hash, :name, :size
  end

  def test_simple
    hh = {:name => 'wane', :size => 123456}
    ah = Apple.new(hh)

    simple_case(hh, ah)

    ah.name  , ah.size   = ah.size  , ah.name
    hh[:name], hh[:size] = hh[:size], hh[:name]

    simple_case(hh, ah)
  end

  def test_nil
    assert_nil Apple.new.name
    assert_nil Apple.new.attr_hash
  end

  def simple_case hh, ah
    assert_equal hh[:name], ah.name
    assert_equal hh[:size], ah.size
    assert_equal hh       , ah.attr_hash
  end
end
