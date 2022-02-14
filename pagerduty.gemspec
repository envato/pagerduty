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
    "Provides a lightweight interface for calling the PagerDuty Events API"
  gem.summary       = "PagerDuty Events API client library"
  gem.homepage      = "https://github.com/envato/pagerduty"
  gem.license       = "MIT"

  gem.metadata      = {
    "bug_tracker_uri"   => "#{gem.homepage}/issues",
    "changelog_uri"     => "#{gem.homepage}/blob/v#{gem.version}/CHANGELOG.md",
    "documentation_uri" => "https://www.rubydoc.info/gems/#{gem.name}/#{gem.version}",
    "homepage_uri"      => gem.homepage,
    "source_code_uri"   => "#{gem.homepage}/tree/v#{gem.version}",
  }

  gem.require_paths = ["lib"]
  gem.files         = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^(?:README|LICENSE|CHANGELOG|lib/)})
  end
  gem.required_ruby_version = ">= 2.3"

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec-given"
  gem.add_development_dependency "rubocop", " < 0.77"
end
