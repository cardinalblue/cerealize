# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cerealize}
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Cardinal Blue", "Lin Jen-Shin (godfat)", "Jaime Cham"]
  s.date = %q{2011-04-28}
  s.description = %q{Serialize out of the Cerealize Box - a drop-in replacement for ActiveRecord's serialize}
  s.email = ["dev (XD) cardinalblue.com"]
  s.extra_rdoc_files = ["CHANGES", "CONTRIBUTORS", "LICENSE", "TODO"]
  s.files = [".gitignore", "CHANGES", "LICENSE", "README", "README.rdoc", "Rakefile", "TODO", "bench/simple.png", "bench/simple.rb", "init.rb", "lib/cerealize.rb", "lib/cerealize/attr_hash.rb", "lib/cerealize/codec/marshal.rb", "lib/cerealize/codec/text.rb", "lib/cerealize/codec/yaml.rb", "lib/cerealize/version.rb", "slide/2010-04-24-cerealize.key/Contents/PkgInfo", "slide/2010-04-24-cerealize.key/QuickLook/Thumbnail.jpg", "slide/2010-04-24-cerealize.key/background.png", "slide/2010-04-24-cerealize.key/cardinal-blue-black_200.png", "slide/2010-04-24-cerealize.key/cereal-box.png", "slide/2010-04-24-cerealize.key/color-profile", "slide/2010-04-24-cerealize.key/index.apxl.gz", "slide/2010-04-24-cerealize.key/simple.png", "slide/2010-04-24-cerealize.key/thumbs/st0-11.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-16.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-19.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-2.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-22.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-27.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-29.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-30.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-32.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-34.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-38.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-40.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-46.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-50.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-51.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-52.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-54.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0-7.tiff", "slide/2010-04-24-cerealize.key/thumbs/st0.tiff", "slide/2010-04-24-cerealize.pdf", "slide/cereal-box.ai", "slide/cereal-box.jpg", "slide/cereal-box.png", "task/gemgem.rb", "test/common.rb", "test/real.rb", "test/stub.rb", "test/test_all_codec.rb", "test/test_attr_hash.rb", "test/test_basic.rb", "test/test_transcode.rb", "CONTRIBUTORS"]
  s.homepage = %q{http://github.com/godfat/}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Serialize out of the Cerealize Box - a drop-in replacement for ActiveRecord's serialize}
  s.test_files = ["test/test_all_codec.rb", "test/test_attr_hash.rb", "test/test_basic.rb", "test/test_transcode.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, ["< 3"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, ["< 3"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, ["< 3"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
  end
end
