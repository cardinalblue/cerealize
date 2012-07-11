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

  should 'no conflict' do
     Cat.respond_to?(:captain).should.equal false
    Boat.respond_to?(:food)   .should.equal false
  end

  should 'cerealize module' do
    ( Cat <  Cat::CerealizeMethods).should.equal true
    (Boat < Boat::CerealizeMethods).should.equal true

    ( Cat < Boat::CerealizeMethods).should.equal nil
    (Boat <  Cat::CerealizeMethods).should.equal nil
  end


  should 'super calling' do
    Dog.new.mood                     .should.equal 'mood: '
    Dog.new(:mood => 'cheerful').mood.should.equal 'mood: cheerful'
  end

  should 'setting nil in hash' do
    apple = Apple.create(:data => {:name => 'pine'})
    apple.data.should.equal({:name => 'pine'})
    apple.name.should.equal 'pine'
    apple.data[:name] = nil
    apple.name.should.equal nil
    apple.save; apple.reload
    apple.name.should.equal nil
    apple.data.should.equal({:name => nil})
  end

  should 'save nil' do
    apple = Apple.find(Apple.create(:data => [5]).id)
    apple.data.should.equal [5]
    apple.update_attributes(:data => nil)
    apple.data.should.equal nil
    Apple.find(apple.id).data.should.equal nil
  end

  should 'encoding yaml' do
    set_encoding(:yaml)
    Boat.create :name => 'yamato', :captain => Person.new('kosaku')
    s = Boat.connection.select_value("SELECT captain FROM boats WHERE name='yamato';")
    s[0..2].should.equal '---'
  end

  should 'encoding marshal' do
    set_encoding(:marshal)
    Boat.create :name => 'santa maria', :captain => Person.new('columbus')
    s = Boat.connection.select_value("SELECT captain FROM boats WHERE name='santa maria';")
    s[0..1].should.equal 'BA'
  end

  should 'cerealize option' do
    Cat.cerealize_option.should.equal(
      {:name => {:class    => String,
                 :encoding => :yaml,
                 :codec    => Cerealize::Codec::Yaml},

       :tail => {:class    => Array,
                 :encoding => :marshal,
                 :codec    => Cerealize::Codec::Marshal,
                 :force_encoding => true},

       :food => {:class    => Hash,
                 :encoding => :marshal,
                 :codec    => Cerealize::Codec::Marshal,
                 :force_encoding => false}})
  end

  should 'inheritance' do
    mood = {:mood => {:class    => String,
                      :encoding => :marshal,
                      :codec    => Cerealize::Codec::Marshal}}
    hook = {:hook => {:class    => Integer,
                      :encoding => :marshal,
                      :codec    => Cerealize::Codec::Marshal}}
       Dog.cerealize_option.should.equal mood.merge(hook)
    BigDog.cerealize_option.should.equal mood.merge(hook)
  end
end
