# frozen_string_literal: true
require "bundler/setup"
require "simplecov"
require "minitest/autorun"
require "ams"
require "fixtures/poro"

module AMS
  class Test < Minitest::Test
    def assert_serialized(expected, serializer)
      assert_equal expected, serializer.serializable_hash
    end
  end
end
