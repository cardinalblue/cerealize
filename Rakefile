# encoding: utf-8

# encoding: utf-8

require "#{dir = File.dirname(__FILE__)}/task/gemgem"
Gemgem.dir = dir

($LOAD_PATH << File.expand_path("#{Gemgem.dir}/lib" )).uniq!

desc 'Generate gemspec'
task 'gem:spec' do
  Gemgem.spec = Gemgem.create do |s|
    require 'cerealize/version'
    s.name        = 'cerealize'
    s.version     = Cerealize::VERSION
    # s.executables = [s.name]

    %w[activerecord].each{ |g| s.add_runtime_dependency(g, '<3') }
    %w[sqlite3-ruby].each{ |g| s.add_development_dependency(g) }

    s.authors     = ['Cardinal Blue', 'Lin Jen-Shin (godfat)', 'Jaime Cham']
    s.email       = ['dev (XD) cardinalblue.com']
  end

  Gemgem.write
end
