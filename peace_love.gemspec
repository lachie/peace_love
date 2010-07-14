# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{peace_love}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lachie Cox"]
  s.date = %q{2010-07-14}
  s.description = %q{A simple mixin layer for enhancing hashes retrieved from MongoDB. It eschews the normal 'mapping' compulsion of mongo libraries.}
  s.email = %q{lachie@smartbomb.com.au}
  s.files = [
    ".gitignore",
     "Gemfile",
     "Rakefile",
     "VERSION",
     "examples/eg.helper.rb",
     "examples/usage.eg.rb",
     "lib/peace_love.rb",
     "lib/peace_love/collection.rb",
     "lib/peace_love/cursor.rb",
     "lib/peace_love/document.rb",
     "lib/peace_love/railtie.rb",
     "peace_love.gemspec"
  ]
  s.homepage = %q{http://github.com/lachie/peace_love}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Peace, Love and Mongo.}
  s.test_files = [
    "examples/eg.helper.rb",
     "examples/usage.eg.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mongo>, ["~> 1.0.0"])
    else
      s.add_dependency(%q<mongo>, ["~> 1.0.0"])
    end
  else
    s.add_dependency(%q<mongo>, ["~> 1.0.0"])
  end
end

