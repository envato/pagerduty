# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in pagerduty.gemspec
gemspec

group :test do
  gem "rspec-given", "< 3.8.1" if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.6")
end
