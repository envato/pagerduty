# encoding: utf-8
require "pagerduty"
require "minitest/autorun"
require "minitest/given"
require "minitest/pride"
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }
