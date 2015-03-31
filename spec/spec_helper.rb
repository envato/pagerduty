# encoding: utf-8
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

Warnings.silenced do
  require "rspec/given"
  require "json"
  require "net/https"
end

require "pagerduty"

RSpec.configure do |config|
  config.color = true
end
