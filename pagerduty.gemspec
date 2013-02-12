# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pagerduty/version'

Gem::Specification.new do |gem|
  gem.name          = "pagerduty"
  gem.version       = Pagerduty::VERSION
  gem.authors       = ["Charlie Somerville"]
  gem.email         = ["charlie@charliesomerville.com"]
  gem.description   = %q{Provides a simple interface for calling into the Pagerduty API}
  gem.summary       = %q{Pagerduty API client library}
  gem.homepage      = "http://github.com/envato/pagerduty"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "json", [">= 1.7.7"]
end
