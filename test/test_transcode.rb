# encoding: utf-8

unless respond_to?(:require_relative, true)
  def require_relative path
    require "#{File.dirname(__FILE__)}/#{path}"
  end
end

require_relative 'common'

describe Cerealize do
  before do
    Cat.delete_all
  end

  should 'no such codec' do
    lambda{
      Cat.dup.send(:cerealize, :bad, Hash, :encoding => :blah)
    }.should.raise(Cerealize::NoSuchCodec)
  end

  should 'no suitable codec if force encoding' do
    cat = Cat.new
    cat[:tail] = '---'
    lambda{
      cat.tail
    }.should.raise(Cerealize::NoSuitableCodec)
  end

  should 'auto transcode yaml' do
    name = 'Nine Tails'
    marshaled_name = Cerealize::Codec::Marshal.encode(name)
    cat = Cat.new
    cat[:name] = marshaled_name
    cat.save
    id = cat.id

    new_cat = Cat.find(id)
    new_cat.name.should.equal name
    new_cat.name.reverse!

    # no change if not saved yet
    new_cat[:name].should.equal marshaled_name
    new_cat.save

    # should be transcode into YAML
    Cerealize::Codec::Yaml.yours?(new_cat[:name]).should.equal true
    new_cat.reload
    Cerealize::Codec::Yaml.yours?(new_cat[:name]).should.equal true
  end

  should 'auto transcode marshal' do
    food = {:a => :b}
    yamled_food = Cerealize::Codec::Yaml.encode(food)
    cat = Cat.new
    cat[:food] = yamled_food
    cat.save
    cat.reload

    cat .food .should.equal food
    cat[:food].should.equal yamled_food
    cat.food.merge!(:c => :d)
    cat.save
    cat.reload

    Cerealize::Codec::Marshal.yours?(cat[:food]).should.equal true
    cat.food.should.equal food.merge(:c => :d)
  end
end
