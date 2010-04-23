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

  depend_on 'activerecord',                       :version => '>=2.3.5'
  # depend_on 'activerecord', :development => true, :version => '>=2.3.5'
  depend_on 'sqlite3-ruby', :development => true

  name    proj
  url     "http://github.com/cardinalblue/#{proj}"
  authors 'Cardinal Blue'
  email   'dev (XD) cardinalblue.com'

  history_file   'CHANGES'
   readme_file   'README'
   ignore_file   '.gitignore'
  rdoc.include   ['\w+']
  rdoc.exclude   ['test', 'doc', 'Rakefile']
}

CLEAN.include Dir['**/*.rbc']

task :default do
  Rake.application.options.show_task_pattern = /./
  Rake.application.display_tasks_and_comments
end

task 'doc:rdoc' do
  sh 'cp -r ~/.gem/ruby/1.9.1/gems/rdoc-2.5.6/lib/rdoc/generator/template/darkfish/* doc/'
end
