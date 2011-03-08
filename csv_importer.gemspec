# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "csv_importer/version"

Gem::Specification.new do |s|
  s.name        = "csv_importer"
  s.version     = CSVImporter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Terry Tai", "Dingding Ye"]
  s.email       = ["poshboytl@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{CSV importer for rails project}
  s.description = %q{To import CSV file in your Rails project with ActiveRecord}

  s.rubyforge_project = "csv_importer"
  
  s.add_dependency('fastercsv')
  s.add_dependency('activerecord', '3.0.4')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
