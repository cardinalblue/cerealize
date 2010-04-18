require 'test_helper'


def debug(*args)
  Rails.logger.debug(*args)
end

class Person
  def initialize(name, age=nil)
    self.name = name
    self.age  = age
  end
  
  ATTR = [ :name, :age, :hat, :pocket ]
  attr_accessor *ATTR

  def ==(other)
    ATTR.all?{|m| send(m) == other.send(m) }
  end
  def eql?(other)
    ATTR.all?{|m| send(m).eql? other.send(m) }
  end
end

class Hat
  def initialize(color); self.color = color; end
  attr_accessor :color
end

class Blob; end

ActiveRecordTester.create_table :boats, :force => true do |t|
  t.string  :name
  t.integer :tonnage
  t.string  :captain
  t.string  :cargo
end
class Boat < ActiveRecord::Base
  include Marshalize
  marshalize :captain
  marshalize :cargo, Blob
end

class MarshalizeTest < ActiveSupport::TestCase
  def setup
    Boat.delete_all
  end
  def teardown
  end
  
  def set_encoding(encoding)
    Boat.send :marshalize, :captain, nil, :encoding => encoding
  end

  test "encoding yaml" do
    set_encoding(:yaml)
    Boat.create :name => 'yamato', :captain => Person.new('kosaku')
    s = Boat.connection.select_value("SELECT captain FROM boats WHERE name='yamato';")
    assert s[0..2] = '---'    
  end
  
  test "encoding marshal" do
    set_encoding(:marshal)
    Boat.create :name => 'santa maria', :captain => Person.new('columbus')
    s = Boat.connection.select_value("SELECT captain FROM boats WHERE name='santa maria';")
    assert s[0..1] = 'BA'    
  end
  
  test 'class checking' do
    Boat.create :name => 'lollypop', :cargo => Blob.new
    Boat.find_by_name 'lollypop'

    Boat.create :name => 'minerva', :cargo => "WRONG KIND"
    assert_raise ActiveRecord::SerializationTypeMismatch do
      Boat.find_by_name('minerva').cargo
    end
  end
  
  [ :yaml, :marshal ].each do |encoding|

    test "#{encoding} basic" do
      set_encoding(encoding)
    
      debug '(0)'
      b = Boat.create(:name => 'pequod')
    
      debug '(1)'
      b.captain = Person.new('ahab')
      b.save!
    
      debug "(2)"
      b = Boat.find_by_name('pequod')
      assert_equal Person, b.captain.class
      assert_equal 'ahab', b.captain.name
    
      b.captain = Person.new('ishmael')             # make sure not frozen!
      assert_equal 'ishmael', b.captain.name
      b.captain.name = 'call me ishmael'
      b.save!
    
      debug '(3)'
      b = Boat.find_by_name('pequod')
      assert_equal 'call me ishmael', b.captain.name
    end

    ['string', {:key1 => 'v', :key2 => [3,4]}].each do |captain|
      test "#{encoding} for #{captain} changed?" do
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

      test "#{encoding} partial update #{action}" do
        set_encoding(encoding)

        Boat.delete_all
    
        b1 = Boat.create :name => 'titanic', :tonnage => 1000
        b1.captain = Person.new 'smith'
        b1.save!

        b1 = Boat.find_by_name 'titanic'
        b1.tonnage += 1000
        if action.included_in? [:read, :read_write]
          b1.captain
        end
        if action.included_in? [:read_write, :write]
          b1.captain = Person.new 'dawson'
        end

        b2 = Boat.find_by_name 'titanic'
        b2.captain = Person.new 'rose'
        b2.save!

        b1.save! # Potentially overwriting save!

        b3 = Boat.find_by_name 'titanic'
        if action.included_in? [:read_write, :write]
          assert_equal 'dawson', b3.captain.name
        elsif action == :none
          assert_equal 'rose', b3.captain.name
        elsif action == :read
          assert b3.captain.name.included_in?(%w{ rose dawson }), 
            "captain.name is #{b3.captain.name}"
        end
      end
    end

    test "#{encoding} just save" do
      set_encoding(encoding)
      b1 = Boat.new :name => 'alinghi'
      b1.save!
      assert_equal nil, Boat.find_by_name('alinghi').captain
    end
    test "#{encoding} just save writing" do
      set_encoding(encoding)
      b1 = Boat.new :name => 'surprise'
      b1.captain = Person.new 'aubrey'
      b1.save!
      assert_equal 'aubrey', Boat.find_by_name('surprise').captain.name
    end
    test "#{encoding} just reading" do
      set_encoding(encoding)
      b1 = Boat.create :name => 'black pearl', :captain => Person.new('sparrow')
      b2 = Boat.find_by_name 'black pearl'
      assert_equal 'sparrow', b2.captain.name
    end
    
    test "#{encoding} deep change" do
      set_encoding(encoding)
      b1 = Boat.create :name => 'bounty', :captain => (Person.new('bligh'))
      
      b2 = Boat.find_by_name 'bounty'
      b2.captain.hat = Hat.new('blue')
      b2.save!
      
      assert_equal 'blue', Boat.find_by_name('bounty').captain.hat.color
    end

    test "#{encoding} deeper change object" do
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

    test "#{encoding} deeper change hash" do
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
  end

  test 'simple hash' do
    b = Boat.new
    h = { :name => 'skipper' }
    b.captain = h
    assert_equal h, b.captain
    b.save
    assert_equal h, b.captain
    b.captain[:actor] = 'alan hale'
    assert_equal 'alan hale', b.captain[:actor]
  end

  test 'check if really saved' do
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

  test 'array marshalize' do
    b = Boat.new
    b.captain = [123, 456]
    b.save
    assert_equal [123, 456], b.captain
    assert_equal [123, 456], Boat.find(b.id).captain
  end
  
  test 'repeated saves' do
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
