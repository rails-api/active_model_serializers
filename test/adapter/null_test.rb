require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class NullTest < ActiveSupport::TestCase
      def setup
        profile = Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
        serializer = ProfileSerializer.new(profile)

        @adapter = Null.new(serializer)
      end

      test 'serializable_hash' do
        assert_equal({}, @adapter.serializable_hash)
      end

      test 'it_returns_empty_json' do
        assert_equal('{}', @adapter.to_json)
      end
    end
  end
end
