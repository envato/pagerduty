# frozen_string_literal: true

source "https://rubygems.org"
gemspec

group :development, :test do
  gem "rake"
  gem "rspec-given", (Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.6") ? "< 3.8.1" : "~> 3")
  gem "rubocop", (Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.4") ? "~> 0" : "~> 1")
end
