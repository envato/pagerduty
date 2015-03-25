require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

task default: [:rubocop, :spec]

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

desc "rubocop compliancy checks"
RuboCop::RakeTask.new(:rubocop)
