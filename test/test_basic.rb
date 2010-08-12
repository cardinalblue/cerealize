# encoding: utf-8

unless respond_to?(:require_relative, true)
  def require_relative path
    require "#{File.dirname(__FILE__)}/#{path}"
  end
end

require_relative 'common'

class BasicTest < Test::Unit::TestCase
  def setup
    Boat.delete_all
  end

  def teardown
  end

  def test_no_conflict
    assert ! Cat.respond_to?(:captain)
    assert !Boat.respond_to?(:food)
  end

  def test_cerealize_module
    assert    Cat <  Cat::CerealizeMethods
    assert   Boat < Boat::CerealizeMethods

    assert !( Cat < Boat::CerealizeMethods)
    assert !(Boat <  Cat::CerealizeMethods)
  end

  def test_super_calling
    assert_equal 'mood: ',         Dog.new.mood
    assert_equal 'mood: cheerful', Dog.new(:mood => 'cheerful').mood
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

  def test_cerealize_option
    assert_equal({:name => {:class    => String,
                            :encoding => :yaml,
                            :codec    => Cerealize::Codec::Yaml},

                  :tail => {:class    => Array,
                            :encoding => :marshal,
                            :codec    => Cerealize::Codec::Marshal,
                            :force_encoding => true},

                  :food => {:class    => Hash,
                            :encoding => :marshal,
                            :codec    => Cerealize::Codec::Marshal,
                            :force_encoding => false}},
                 Cat.cerealize_option)
  end

  def test_inheritance
    mood = {:mood => {:class    => String,
                      :encoding => :marshal,
                      :codec    => Cerealize::Codec::Marshal}}
    hook = {:hook => {:class    => Integer,
                      :encoding => :marshal,
                      :codec    => Cerealize::Codec::Marshal}}
    assert_equal(mood            ,    Dog.cerealize_option)
    assert_equal(mood.merge(hook), BigDog.cerealize_option)
  end

end
