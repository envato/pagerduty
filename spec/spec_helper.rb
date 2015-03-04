# encoding: utf-8
require 'pagerduty'
require 'rspec/given'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.color = true
end
