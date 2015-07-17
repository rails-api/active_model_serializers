require 'test_helper'

module ActiveModel
  class Serializer
    class RootTest < Minitest::Test

      def setup
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @profile_serializer = ProfileSerializer.new(@post, {root: 'smth'})
      end

      def test_overwrite_root
        setup
        assert_equal('smth', @profile_serializer.json_key)
      end

    end
  end
end
