# -*- encoding: utf-8 -*-
require File.expand_path('../lib/yahoo-group-data/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Will Jessop"]
  gem.email         = ["will@willj.net"]
  gem.description   = %q{A lib to fetch public Yahoo group data}
  gem.summary       = %q{A lib to fetch the publicly available Yahoo group data from a Yahoo groups page}
  gem.homepage      = "https://github.com/wjessop/yahoo-group-data"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "yahoo-group-data"
  gem.require_paths = ["lib"]
  gem.version       = YahooGroupData::VERSION

  gem.add_dependency 'nokogiri', '~> 1.5'
  gem.add_dependency 'curb', '~> 0.8'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'simplecov'
end
