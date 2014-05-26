# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pagerduty/version'

Gem::Specification.new do |gem|
  gem.name          = "pagerduty"
  gem.version       = Pagerduty::VERSION
  gem.authors       = ["Charlie Somerville", "Orien Madgwick"]
  gem.email         = ["charlie@charliesomerville.com", "_@orien.io"]
  gem.description   = %q{Provides a lightweight interface for calling the PagerDuty Integration API}
  gem.summary       = %q{Pagerduty Integration API client library}
  gem.homepage      = "http://github.com/envato/pagerduty"
  gem.license       = "MIT"

  gem.post_install_message = <<-MSG
If upgrading to pagerduty 2.0.0 please note the API changes:
https://github.com/envato/pagerduty#upgrading-to-version-200
  MSG

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "json", ">= 1.7.7"
  gem.add_development_dependency "bundler", "~> 1.6"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec-given"
end
