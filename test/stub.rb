# encoding: utf-8

class Person
  def initialize(name, age=nil)
    self.name = name
    self.age  = age
  end

  ATTR = [ :name, :age, :hat, :pocket ]
  attr_accessor(*ATTR)

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
