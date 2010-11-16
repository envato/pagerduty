require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "pagerduty"
  gem.homepage = "http://github.com/envato/pagerduty"
  gem.license = "MIT"
  gem.summary = "Pagerduty API client library"
  gem.description = "Provides a simple interface for calling into the Pagerduty API"
  gem.email = "charlie@charliesomerville.com"
  gem.authors = ["charliesome"]
  # Include your dependencies in Gemfile.
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "pagerduty #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
