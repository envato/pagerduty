# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pagerduty/version"

Gem::Specification.new do |gem|
  gem.name          = "pagerduty"
  gem.version       = Pagerduty::VERSION
  gem.authors       = ["Charlie Somerville", "Orien Madgwick"]
  gem.email         = ["charlie@charliesomerville.com", "_@orien.io"]
  gem.description   =
    "Provides a lightweight interface for calling the PagerDuty Integration API"
  gem.summary       = "Pagerduty Integration API client library"
  gem.homepage      = "http://github.com/envato/pagerduty"
  gem.license       = "MIT"

  gem.metadata      = {
    "bug_tracker_uri"   => "https://github.com/envato/pagerduty/issues",
    "documentation_uri" => "https://www.rubydoc.info/gems/pagerduty/#{gem.version}",
    "source_code_uri"   => "https://github.com/envato/pagerduty/tree/v#{gem.version}",
  }

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "json", ">= 1.7.7"
  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec-given"
  gem.add_development_dependency "rubocop"
end
