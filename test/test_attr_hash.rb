
unless respond_to?(:require_relative, true)
  def require_relative path
    require "#{File.dirname(__FILE__)}/#{path}"
  end
end

require_relative 'common'

describe 'attr_hash' do
  def simple_case hh, ah
    ah.name.should.equal hh[:name]
    ah.size.should.equal hh[:size]
    ah.data.should.equal hh
  end

  should 'simple' do
    hh = {:name => 'wane', :size => 123456}
    ah = Apple.new(hh)

    simple_case(hh, ah)

    ah.name  , ah.size   = ah.size  , ah.name
    hh[:name], hh[:size] = hh[:size], hh[:name]

    simple_case(hh, ah)
  end

  should 'nil' do
    Apple.new.name.should.equal nil
    Apple.new.data.should.equal nil
  end

  should 'dont save twice' do
    apple = Apple.create(:name => 'banana')
    apple.updated_at.should.not.equal nil

    Apple.record_timestamps = false
    apple.update_attributes(:updated_at => nil)
    Apple.record_timestamps = true
    apple2 = Apple.find(apple.id)
    apple2.updated_at.should.equal nil
    apple2.update_attributes :name => 'banana'
    apple2.updated_at.should.equal nil
    apple2.update_attributes :name => 'pineapple'
    apple2.updated_at.should.not.equal nil
  end
end
