# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cerealize}
  s.version = "0.8.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Cardinal Blue", "Lin Jen-Shin (aka godfat 真常)", "Jaime Cham"]
  s.date = %q{2010-09-20}
  s.description = %q{ Serialize out of the Cerealize Box
 - a drop-in replacement for ActiveRecord's serialize

 It can auto transcode old encoding (yaml if you're using AR's serialize),
 to new encoding (marshal, json, you name it) without any migration.

 Current supported encoding:
 1. YAML
 2. Marshal
 3. JSON (planned)

 Current supported ORM:
 1. ActiveRecord (tested with 2.3.5)
 2. DataMapper (planned)}
  s.email = %q{dev (XD) cardinalblue.com}
  s.extra_rdoc_files = ["CHANGES", "LICENSE", "README", "TODO", "bench/simple.png", "cerealize.gemspec"]
  s.files = ["CHANGES", "LICENSE", "README", "README.rdoc", "Rakefile", "TODO", "bench/simple.png", "bench/simple.rb", "cerealize.gemspec", "init.rb", "lib/cerealize.rb", "lib/cerealize/attr_hash.rb", "lib/cerealize/codec/marshal.rb", "lib/cerealize/codec/yaml.rb", "lib/cerealize/version.rb", "test/common.rb", "test/real.rb", "test/stub.rb", "test/test_all_codec.rb", "test/test_attr_hash.rb", "test/test_basic.rb", "test/test_transcode.rb"]
  s.homepage = %q{http://github.com/cardinalblue/cerealize}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{cerealize}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Serialize out of the Cerealize Box - a drop-in replacement for ActiveRecord's serialize  It can auto transcode old encoding (yaml if you're using AR's serialize), to new encoding (marshal, json, you name it) without any migration}
  s.test_files = ["test/test_all_codec.rb", "test/test_attr_hash.rb", "test/test_basic.rb", "test/test_transcode.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, ["< 3"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 1.3.1"])
      s.add_development_dependency(%q<bones>, [">= 3.4.7"])
    else
      s.add_dependency(%q<activerecord>, ["< 3"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.1"])
      s.add_dependency(%q<bones>, [">= 3.4.7"])
    end
  else
    s.add_dependency(%q<activerecord>, ["< 3"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.1"])
    s.add_dependency(%q<bones>, [">= 3.4.7"])
  end
end
