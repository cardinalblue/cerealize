
require 'benchmark'

require 'active_record'
require 'cerealize'

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

[:hats, :cats].each{ |table|
  ActiveRecord::Base.connection.create_table table, :force => true do |t|
    t.text :box
  end
}

class Hat < ActiveRecord::Base
  serialize :box, Hash
end

class Cat < ActiveRecord::Base
  include Cerealize
  cerealize :box, Hash
end

def simple klass
  box = Hash[(0..300).zip(301..600)]
  mox = box.invert
  klass.find(klass.create(:box => box).id).
        update_attributes(:box => mox)
end

Times = 100

Benchmark.bmbm{ |bm|
  bm.report('serialize (build in ActiveRecord)') do
    Times.times{ simple(Hat) }
  end

  bm.report('cerealize') do
    Times.times{ simple(Cat) }
  end
}
