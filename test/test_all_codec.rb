# encoding: utf-8

unless respond_to?(:require_relative, true)
  def require_relative path
    require "#{File.dirname(__FILE__)}/#{path}"
  end
end

require_relative 'common'

describe Cerealize do
  before do
    Boat.delete_all
  end

  Cerealize.codec_names.each do |encoding|

    should "#{encoding} basic" do
      set_encoding(encoding)

      b = Boat.create(:name => 'pequod')

      b.captain = Person.new('ahab')
      b.save!

      b = Boat.find_by_name('pequod')
      b.captain.class.should.equal Person
      b.captain.name .should.equal 'ahab'

      b.captain = Person.new('ishmael')             # make sure not frozen!
      b.captain.name.should.equal 'ishmael'
      b.captain.name = 'call me ishmael'
      b.save!

      b = Boat.find_by_name('pequod')
      b.captain.name.should.equal 'call me ishmael'
    end

    ['string', {:key1 => 'v', :key2 => [3,4]}].each do |captain|
      should "#{encoding} for #{captain}_changed?" do
        b = Boat.create(:captain => captain)
        b.changed?.should.equal false
        b.captain = b.captain
        b.changed?.should.equal false
        b.captain = captain
        b.changed?.should.equal false
        b.captain = captain.dup
        b.changed?.should.equal false
        b.captain = case captain
                      when String; captain.reverse
                      when Hash;   captain.merge(:key2 => [1,2])
                    end
        b.changed?.should.equal true
      end
    end

    [ :none, :read, :read_write, :write ].each do |action|

      should "#{encoding} partial update #{action}" do
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
          b3.captain.name.should.equal 'dawson'
        elsif action == :none
          b3.captain.name.should.equal 'rose'
        elsif action == :read
          %w{ rose dawson }.should.include?(b3.captain.name)
        end
      end
    end

    should "#{encoding} just save" do
      set_encoding(encoding)
      b1 = Boat.new :name => 'alinghi'
      b1.save!
      Boat.find_by_name('alinghi').captain.should.equal nil
    end

    should "#{encoding} just save writing" do
      set_encoding(encoding)
      b1 = Boat.new :name => 'surprise'
      b1.captain = Person.new 'aubrey'
      b1.save!
      Boat.find_by_name('surprise').captain.name.should.equal 'aubrey'
    end

    should "#{encoding} just reading" do
      set_encoding(encoding)
      b1 = Boat.create :name => 'black pearl', :captain => Person.new('sparrow')
      b2 = Boat.find_by_name 'black pearl'
      b2.captain.name.should.equal 'sparrow'
    end

    should "#{encoding} deep change" do
      set_encoding(encoding)
      b1 = Boat.create :name => 'bounty', :captain => (Person.new('bligh'))

      b2 = Boat.find_by_name 'bounty'
      b2.captain.hat = Hat.new('blue')
      b2.save!

      Boat.find_by_name('bounty').captain.hat.color.should.equal 'blue'
    end

    should "#{encoding} deeper change object" do
      set_encoding(encoding)
      b1 = Boat.create :name => 'bounty', :captain => (Person.new('bligh'))

      b2 = Boat.find_by_name 'bounty'
      b2.captain.pocket = [ :pounds ]
      b2.save!

      b2 = Boat.find_by_name 'bounty'
      b2.captain.pocket << :francs
      b2.save!

      Boat.find_by_name('bounty').captain.pocket.should.equal [:pounds, :francs]
    end

    should "#{encoding} deeper change hash" do
      set_encoding(encoding)
      b1 = Boat.create :name => 'bounty', :captain => { :name => :bligh }

      b2 = Boat.find_by_name 'bounty'
      b2.captain[:pocket] = [ :pounds ]
      b2.save!

      b2 = Boat.find_by_name 'bounty'
      b2.captain[:pocket] << :francs
      b2.save!

      Boat.find_by_name('bounty').captain[:pocket].should.equal [:pounds, :francs]
    end


    should "#{encoding} class checking" do
      set_encoding(encoding)
      Boat.create :name => 'lollypop', :cargo => Blob.new
      Boat.find_by_name 'lollypop'

      lambda{
        Boat.create :name => 'minerva', :cargo => "WRONG KIND"
      }.should.raise ActiveRecord::SerializationTypeMismatch
    end

    should "#{encoding} simple hash" do
      set_encoding(encoding)
      b = Boat.new
      h = { :name => 'skipper' }
      b.captain = h
      b.captain.should.equal h
      b.save
      b.captain.should.equal h
      b.captain[:actor] = 'alan hale'
      b.captain[:actor].should.equal 'alan hale'
    end

    should "#{encoding} check if really saved" do
      set_encoding(encoding)
      b = Boat.new
      b.captain = { :name => 'ramius' }
      b.save

      b2 = Boat.find(b.id)
      b2.captain.should.equal b.captain
      b2.captain[:nationality] = 'russian'
      b2.save

      b3 = Boat.find(b2.id)
      b3.captain[:nationality].should.equal 'russian'
    end

    should "#{encoding} array cerealize" do
      set_encoding(encoding)
      b = Boat.new
      b.captain = [123, 456]
      b.save
      b.captain.should.equal [123, 456]
      Boat.find(b.id).captain.should.equal [123, 456]
    end

    should "#{encoding} repeated saves" do
      set_encoding(encoding)
      b = Boat.new
      b.captain = { :name => 'kirk', :age => 23 }
      b.save

               b.captain[:age].should.equal 23
      Boat.first.captain[:age].should.equal 23

      b.captain[:age] += 1
      b.save
               b.captain[:age].should.equal 24
      Boat.first.captain[:age].should.equal 24

      b.captain[:age] += 1
      b.save
      b.captain[:age] += 1
      b.save
               b.captain[:age].should.equal 26
      Boat.first.captain[:age].should.equal 26

      b.captain[:age] += 1
      b.save
      b.captain[:age] += 1
      b.save
      b.captain[:age] += 1
      b.save
               b.captain[:age].should.equal 29
      Boat.first.captain[:age].should.equal 29

    end
  end
end
