# frozen_string_literal: true

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
