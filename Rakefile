require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rdoc/task"

task :default => :spec

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "pagerduty #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
