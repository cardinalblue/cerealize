# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cerealize}
  s.version = "0.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Cardinal Blue", "Lin Jen-Shin (aka godfat 真常)", "Jaime Cham"]
  s.date = %q{2010-07-21}
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
  s.files = ["CHANGES", "LICENSE", "README", "README.rdoc", "Rakefile", "TODO", "bench/simple.png", "bench/simple.rb", "cerealize.gemspec", "init.rb", "lib/cerealize.rb", "lib/cerealize/attr_hash.rb", "lib/cerealize/codec/marshal.rb", "lib/cerealize/codec/yaml.rb", "lib/cerealize/version.rb", "slide/2010-04-24-cerealize.key/Contents/PkgInfo", "slide/2010-04-24-cerealize.key/QuickLook/Thumbnail.jpg", "slide/2010-04-24-cerealize.key/background.png", "slide/2010-04-24-cerealize.key/cardinal-blue-black_200.png", "slide/2010-04-24-cerealize.key/cereal-box.png", "slide/2010-04-24-cerealize.key/color-profile", "slide/2010-04-24-cerealize.key/index.apxl.gz", "slide/2010-04-24-cerealize.key/simple.png", "slide/2010-04-24-cerealize.key/thumbs/st0-11.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-16.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-19.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-2.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-22.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-27.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-29.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-30.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-32.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-34.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-38.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-40.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-46.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-50.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-51.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-52.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-54.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-7.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0.tiff", "slide/2010-04-24-cerealize.pdf", "slide/cereal-box.ai", "slide/cereal-box.jpg", "slide/cereal-box.png", "test/common.rb", "test/real.rb", "test/stub.rb", "test/test_all_codec.rb", "test/test_attr_hash.rb", "test/test_basic.rb", "test/test_transcode.rb"]
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
      s.add_runtime_dependency(%q<activerecord>, [">= 2.3.5"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 1.3.1"])
      s.add_development_dependency(%q<bones>, [">= 3.4.7"])
    else
      s.add_dependency(%q<activerecord>, [">= 2.3.5"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.1"])
      s.add_dependency(%q<bones>, [">= 3.4.7"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 2.3.5"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.1"])
    s.add_dependency(%q<bones>, [">= 3.4.7"])
  end
end
