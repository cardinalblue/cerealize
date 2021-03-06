# encoding: utf-8

adapter = if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
            'jdbcsqlite3'
          else
            'sqlite3'
          end

ActiveRecord::Base.establish_connection(
  :adapter  => adapter,
  :database => ':memory:'
)

# ===================================================================

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

# ===================================================================

class Cat < ActiveRecord::Base
  include Cerealize
  cerealize :name, String, :encoding => :yaml
  cerealize :tail, Array,  :encoding => :marshal, :force_encoding => true
  cerealize :food, Hash,   :encoding => :marshal, :force_encoding => false
end

ActiveRecord::Base.connection.create_table :cats, :force => true do |t|
  t.text :name
  t.text :tail
  t.text :food
end

# ===================================================================

class Dog < ActiveRecord::Base
  include Cerealize

  cerealize :mood, String
  def mood
    "mood: #{super}"
  end
end

class BigDog < Dog
  cerealize :hook, Integer
end

ActiveRecord::Base.connection.create_table :dogs, :force => true do |t|
  t.text :mood, :hook
end

# ===================================================================

class Apple < ActiveRecord::Base
  include Cerealize
  cerealize :data
  attr_hash :data, [:name, :size]
end

class Pineapple < Apple
  before_save :enlarge
  def enlarge
    self.size *= 2
    # data_update_if_dirty
  end
end

ActiveRecord::Base.connection.create_table :apples, :force => true do |t|
  t.text :data
  t.timestamps :updated_at
end
