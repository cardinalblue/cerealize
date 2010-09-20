# encoding: utf-8

begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
proj = 'cerealize'
require "#{proj}/version"

Bones{
  ruby_opts [''] # silence warning for now

  version Cerealize::VERSION

  depend_on 'activerecord',                       :version => '<3'
  # depend_on 'activerecord', :development => true, :version => '>=2.3.5'
  depend_on 'sqlite3-ruby', :development => true

  name    proj
  url     "http://github.com/cardinalblue/#{proj}"
  authors ['Cardinal Blue', 'Lin Jen-Shin (aka godfat 真常)', 'Jaime Cham']
  email   'dev (XD) cardinalblue.com'

  history_file   'CHANGES'
   readme_file   'README'
   ignore_file   '.gitignore'
  rdoc.include   ['\w+']
  rdoc.exclude   ['test', 'doc', 'Rakefile', 'slide']
}

CLEAN.include Dir['**/*.rbc']

task :default do
  Rake.application.options.show_task_pattern = /./
  Rake.application.display_tasks_and_comments
end
