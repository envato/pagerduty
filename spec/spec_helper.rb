# encoding: utf-8
require "pagerduty"
require "minitest/autorun"
require "minitest/given"
require "minitest/pride"
require "mocha/mini_test"
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }
