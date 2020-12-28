# frozen_string_literal: true

require "net/https"

# Net::HTTPClientException was introduced in Ruby 2.6 as a better named
# replacement for Net::HTTPServerException
#
# https://bugs.ruby-lang.org/issues/14688
#
# This allows use of the new class name while running the test suite on Rubies
# older than version 2.6.
unless defined?(Net::HTTPClientException)
  Net::HTTPClientException = Net::HTTPServerException
end
