# frozen_string_literal: true

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require f }

Warnings.silenced do
  require "rspec/given"
  require "json"
  require "net/https"
end

require "pagerduty"

RSpec.configure do |config|
  config.color = true
end
