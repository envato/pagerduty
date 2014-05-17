require "bundler/gem_tasks"
require "rake/testtask"
require "rdoc/task"

task :default => :spec

Rake::TestTask.new(:spec) do |t|
  t.libs << "spec"
  t.test_files = Dir.glob("spec/**/*_spec.rb")
end

RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "pagerduty #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
