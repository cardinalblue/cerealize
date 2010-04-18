# encoding: utf-8

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

class Boat < ActiveRecord::Base
  include Cerealize
  cerealize :captain
  cerealize :cargo, Blob
end

ActiveRecord::Base.connection.create_table :boats, :force => true do |t|
  t.string  :name
  t.integer :tonnage
  t.string  :captain
  t.string  :cargo
end



class Cat < ActiveRecord::Base
  include Cerealize
  cerealize :name, String, :encoding => :yaml
  cerealize :tail, Array,  :encoding => :marshal, :force_encoding => true
  cerealize :food, Hash,   :encoding => :marshal
end

ActiveRecord::Base.connection.create_table :cats, :force => true do |t|
  t.text :name
  t.text :tail
  t.text :food
end
