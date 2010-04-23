
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

__END__
> system_profiler -detailLevel mini | grep -A 15 'Hardware Overview:'
    Hardware Overview:

      Model Name: MacBook
      Model Identifier: MacBook2,1
      Processor Name: Intel Core 2 Duo
      Processor Speed: 2.16 GHz
      Number Of Processors: 1
      Total Number Of Cores: 2
      L2 Cache: 4 MB
      Memory: 3 GB
      Bus Speed: 667 MHz
      Boot ROM Version: MB21.00A5.B07
      SMC Version (system): 1.17f0
      Sudden Motion Sensor:
          State: Enabled

> uname -a
Darwin godfat.local 10.3.0 Darwin Kernel Version 10.3.0: Fri Feb 26 11:58:09 PST 2010; root:xnu-1504.3.12~1/RELEASE_I386 i386 i386

> ruby -v
ruby 1.9.1p378 (2010-01-10 revision 26273) [i386-darwin10]

> ruby -I lib bench/simple.rb
Rehearsal ---------------------------------------------------------------------
serialize (build in ActiveRecord)   4.050000   0.080000   4.130000 (  4.459223)
cerealize                           0.810000   0.010000   0.820000 (  1.119697)
------------------------------------------------------------ total: 4.950000sec

                                        user     system      total        real
serialize (build in ActiveRecord)   3.870000   0.070000   3.940000 (  4.299835)
cerealize                           0.690000   0.010000   0.700000 (  0.733006)

http://chart.apis.google.com/chart?cht=bvg&chs=350x250&chd=t:85.9967,14.66012&chxl=0:|serialize|cerealize&chxt=x,y&chbh=150&chxr=1,0,5

http://code.google.com/apis/chart/docs/chart_playground.html

cht=bvg
chs=350x250
chd=t:85.9967,14.66012
chxl=0:|serialize|cerealize
chxt=x,y
chbh=150
chxr=1,0,5
