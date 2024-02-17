# frozen_string_literal: true

Warning[:deprecated] = true if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.7.2")

module Warnings
  def self.silenced(&block)
    with_flag(nil, &block)
  end

  def self.with_flag(flag)
    old_verbose = $VERBOSE
    $VERBOSE = flag
    yield
  ensure
    $VERBOSE = old_verbose
  end
end
