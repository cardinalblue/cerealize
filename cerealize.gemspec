# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cerealize}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [
  %q{Cardinal Blue},
  %q{Lin Jen-Shin (godfat)},
  %q{Jaime Cham}]
  s.date = %q{2011-06-29}
  s.description = %q{ Serialize out of the Cerealize Box - a drop-in replacement for ActiveRecord's serialize

 It can auto transcode old encoding (yaml if you're using AR's serialize),
 to new encoding (marshal, json, you name it) without any migration.}
  s.email = [%q{dev (XD) cardinalblue.com}]
  s.extra_rdoc_files = [
  %q{CHANGES},
  %q{CONTRIBUTORS},
  %q{LICENSE},
  %q{TODO}]
  s.files = [
  %q{.gitignore},
  %q{.gitmodules},
  %q{CHANGES},
  %q{CONTRIBUTORS},
  %q{Gemfile},
  %q{LICENSE},
  %q{README},
  %q{README.rdoc},
  %q{Rakefile},
  %q{TODO},
  %q{bench/simple.png},
  %q{bench/simple.rb},
  %q{cerealize.gemspec},
  %q{init.rb},
  %q{lib/cerealize.rb},
  %q{lib/cerealize/attr_hash.rb},
  %q{lib/cerealize/codec/marshal.rb},
  %q{lib/cerealize/codec/text.rb},
  %q{lib/cerealize/codec/yaml.rb},
  %q{lib/cerealize/version.rb},
  %q{task/.gitignore},
  %q{task/gemgem.rb},
  %q{test/common.rb},
  %q{test/real.rb},
  %q{test/stub.rb},
  %q{test/test_all_codec.rb},
  %q{test/test_attr_hash.rb},
  %q{test/test_basic.rb},
  %q{test/test_transcode.rb}]
  s.homepage = %q{https://github.com/cardinalblue/cerealize}
  s.rdoc_options = [
  %q{--main},
  %q{README}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Serialize out of the Cerealize Box - a drop-in replacement for ActiveRecord's serialize}
  s.test_files = [
  %q{test/test_all_codec.rb},
  %q{test/test_attr_hash.rb},
  %q{test/test_basic.rb},
  %q{test/test_transcode.rb}]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 0"])
      s.add_development_dependency(%q<bacon>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, [">= 0"])
      s.add_dependency(%q<bacon>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 0"])
    s.add_dependency(%q<bacon>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
  end
end
