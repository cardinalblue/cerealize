# encoding: utf-8

unless respond_to?(:require_relative, true)
  def require_relative path
    require "#{File.dirname(__FILE__)}/#{path}"
  end
end

require_relative 'common'

class AllCodecTest < Test::Unit::TestCase
  def setup
    Boat.delete_all
  end

  def teardown
  end

  Cerealize.codec_names.each do |encoding|

    define_method "test_#{encoding}_basic" do
      set_encoding(encoding)

      b = Boat.create(:name => 'pequod')

      b.captain = Person.new('ahab')
      b.save!

      b = Boat.find_by_name('pequod')
      assert_equal Person, b.captain.class
      assert_equal 'ahab', b.captain.name

      b.captain = Person.new('ishmael')             # make sure not frozen!
      assert_equal 'ishmael', b.captain.name
      b.captain.name = 'call me ishmael'
      b.save!

      b = Boat.find_by_name('pequod')
      assert_equal 'call me ishmael', b.captain.name
    end

    ['string', {:key1 => 'v', :key2 => [3,4]}].each do |captain|
      define_method "test_#{encoding}_for_#{captain}_changed?" do
        b = Boat.create(:captain => captain)
        assert !b.changed?
        b.captain = b.captain
        assert !b.changed?
        b.captain = captain
        assert !b.changed?
        b.captain = captain.dup
        assert !b.changed?
        b.captain = case captain
                      when String; captain.reverse
                      when Hash;   captain.merge(:key2 => [1,2])
                    end
        assert b.changed?
      end
    end

    [ :none, :read, :read_write, :write ].each do |action|

      define_method "test_#{encoding}_partial_update_#{action}" do
        set_encoding(encoding)

        Boat.delete_all

        b1 = Boat.create :name => 'titanic', :tonnage => 1000
        b1.captain = Person.new 'smith'
        b1.save!

        b1 = Boat.find_by_name 'titanic'
        b1.tonnage += 1000
        if [:read, :read_write].include?(action)
          b1.captain
        end
        if [:read_write, :write].include?(action)
          b1.captain = Person.new 'dawson'
        end

        b2 = Boat.find_by_name 'titanic'
        b2.captain = Person.new 'rose'
        b2.save!

        b1.save! # Potentially overwriting save!

        b3 = Boat.find_by_name 'titanic'
        if [:read_write, :write].include?(action)
          assert_equal 'dawson', b3.captain.name
        elsif action == :none
          assert_equal 'rose', b3.captain.name
        elsif action == :read
          assert %w{ rose dawson }.include?(b3.captain.name),
            "captain.name is #{b3.captain.name}"
        end
      end
    end

    define_method "test_#{encoding}_just_save" do
      set_encoding(encoding)
      b1 = Boat.new :name => 'alinghi'
      b1.save!
      assert_equal nil, Boat.find_by_name('alinghi').captain
    end

    define_method "test_#{encoding}_just_save_writing" do
      set_encoding(encoding)
      b1 = Boat.new :name => 'surprise'
      b1.captain = Person.new 'aubrey'
      b1.save!
      assert_equal 'aubrey', Boat.find_by_name('surprise').captain.name
    end

    define_method "test_#{encoding}_just_reading" do
      set_encoding(encoding)
      b1 = Boat.create :name => 'black pearl', :captain => Person.new('sparrow')
      b2 = Boat.find_by_name 'black pearl'
      assert_equal 'sparrow', b2.captain.name
    end

    define_method "test_#{encoding}_deep_change" do
      set_encoding(encoding)
      b1 = Boat.create :name => 'bounty', :captain => (Person.new('bligh'))

      b2 = Boat.find_by_name 'bounty'
      b2.captain.hat = Hat.new('blue')
      b2.save!

      assert_equal 'blue', Boat.find_by_name('bounty').captain.hat.color
    end

    define_method "test_#{encoding}_deeper_change_object" do
      set_encoding(encoding)
      b1 = Boat.create :name => 'bounty', :captain => (Person.new('bligh'))

      b2 = Boat.find_by_name 'bounty'
      b2.captain.pocket = [ :pounds ]
      b2.save!

      b2 = Boat.find_by_name 'bounty'
      b2.captain.pocket << :francs
      b2.save!

      assert_equal [ :pounds, :francs ], Boat.find_by_name('bounty').captain.pocket
    end

    define_method "test_#{encoding}_deeper_change_hash" do
      set_encoding(encoding)
      b1 = Boat.create :name => 'bounty', :captain => { :name => :bligh }

      b2 = Boat.find_by_name 'bounty'
      b2.captain[:pocket] = [ :pounds ]
      b2.save!

      b2 = Boat.find_by_name 'bounty'
      b2.captain[:pocket] << :francs
      b2.save!

      assert_equal [ :pounds, :francs ], Boat.find_by_name('bounty').captain[:pocket]
    end


    define_method "test_#{encoding}_class_checking" do
      set_encoding(encoding)
      Boat.create :name => 'lollypop', :cargo => Blob.new
      Boat.find_by_name 'lollypop'

      Boat.create :name => 'minerva', :cargo => "WRONG KIND"
      assert_raise ActiveRecord::SerializationTypeMismatch do
        Boat.find_by_name('minerva').cargo
      end
    end

    define_method "test_#{encoding}_simple_hash" do
      set_encoding(encoding)
      b = Boat.new
      h = { :name => 'skipper' }
      b.captain = h
      assert_equal h, b.captain
      b.save
      assert_equal h, b.captain
      b.captain[:actor] = 'alan hale'
      assert_equal 'alan hale', b.captain[:actor]
    end

    define_method "test_#{encoding}_check_if_really_saved" do
      set_encoding(encoding)
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

    define_method "test_#{encoding}_array_cerealize" do
      set_encoding(encoding)
      b = Boat.new
      b.captain = [123, 456]
      b.save
      assert_equal [123, 456], b.captain
      assert_equal [123, 456], Boat.find(b.id).captain
    end

    define_method "test_#{encoding}_repeated_saves" do
      set_encoding(encoding)
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
end
