# encoding: utf-8

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Base.connection.create_table :boats, :force => true do |t|
  t.string  :name
  t.integer :tonnage
  t.string  :captain
  t.string  :cargo
end

class Boat < ActiveRecord::Base
  include Cerealize
  cerealize :captain
  cerealize :cargo, Blob
end
