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
  version Cerealize::VERSION

  depend_on 'activerecord',                       :version => '>=2.3.5'
  # depend_on 'activerecord', :development => true, :version => '>=2.3.5'

  name    proj
  url     "http://github.com/cardinalblue/#{proj}"
  authors 'Cardinal Blue'
  email   'dev (XD) cardinalblue.com'

  history_file   'CHANGES'
   readme_file   'README'
   ignore_file   '.gitignore'
  rdoc.include   ['\w+']
}

CLEAN.include Dir['**/*.rbc']

task :default do
  Rake.application.options.show_task_pattern = /./
  Rake.application.display_tasks_and_comments
end
