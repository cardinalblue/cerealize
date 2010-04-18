# encoding: utf-8

require 'rubygems' if RUBY_VERSION < '1.9.1'
require 'cerealize'

require 'test/stub'
require 'test/helper'
require 'test/helper_active_record'

require 'test/unit'

class BasicTest < Test::Unit::TestCase
  def setup
    Boat.delete_all
  end

  def teardown
  end

  def test_encoding_yaml
    set_encoding(:yaml)
    Boat.create :name => 'yamato', :captain => Person.new('kosaku')
    s = Boat.connection.select_value("SELECT captain FROM boats WHERE name='yamato';")
    assert s[0..2] = '---'
  end

  def test_encoding_marshal
    set_encoding(:marshal)
    Boat.create :name => 'santa maria', :captain => Person.new('columbus')
    s = Boat.connection.select_value("SELECT captain FROM boats WHERE name='santa maria';")
    assert s[0..1] = 'BA'
  end

end
