
unless respond_to?(:require_relative, true)
  def require_relative path
    require "#{File.dirname(__FILE__)}/#{path}"
  end
end

require_relative 'common'

class AttrHashTest < Test::Unit::TestCase
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
    assert_nil Apple.new.data
  end

  def simple_case hh, ah
    assert_equal hh[:name], ah.name
    assert_equal hh[:size], ah.size
    assert_equal hh       , ah.data
  end
end
