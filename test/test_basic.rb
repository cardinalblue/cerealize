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

  def test_class_checking
    Boat.create :name => 'lollypop', :cargo => Blob.new
    Boat.find_by_name 'lollypop'

    Boat.create :name => 'minerva', :cargo => "WRONG KIND"
    assert_raise ActiveRecord::SerializationTypeMismatch do
      Boat.find_by_name('minerva').cargo
    end
  end

  def test_simple_hash
    b = Boat.new
    h = { :name => 'skipper' }
    b.captain = h
    assert_equal h, b.captain
    b.save
    assert_equal h, b.captain
    b.captain[:actor] = 'alan hale'
    assert_equal 'alan hale', b.captain[:actor]
  end

  def test_check_if_really_saved
    b = Boat.new
    b.captain = { :name => 'ramius' }
    b.save

    b2 = Boat.find(b.id)
    assert_equal b.captain, b2.captain
    b2.captain[:nationality] = 'russian'
    b2.save

    b3 = Boat.find(b2.id)
    assert_equal 'russian', b3.captain[:nationality]
  end

  def test_array_cerealize
    b = Boat.new
    b.captain = [123, 456]
    b.save
    assert_equal [123, 456], b.captain
    assert_equal [123, 456], Boat.find(b.id).captain
  end

  def test_repeated_saves
    b = Boat.new
    b.captain = { :name => 'kirk', :age => 23 }
    b.save

    assert_equal 23, b.captain[:age]
    assert_equal 23, Boat.first.captain[:age]

    b.captain[:age] += 1
    b.save
    assert_equal 24, b.captain[:age]
    assert_equal 24, Boat.first.captain[:age]

    b.captain[:age] += 1
    b.save
    b.captain[:age] += 1
    b.save
    assert_equal 26, b.captain[:age]
    assert_equal 26, Boat.first.captain[:age]

    b.captain[:age] += 1
    b.save
    b.captain[:age] += 1
    b.save
    b.captain[:age] += 1
    b.save
    assert_equal 29, b.captain[:age]
    assert_equal 29, Boat.first.captain[:age]

  end
end
