require 'test_helper'

module ActiveModel
  class Serializer
    class UrlTest < Minitest::Test
      def setup
        profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @profile_serializer = ProfileSerializer.new(profile)
      end

      def test_responds_to_url_for
        assert_respond_to @profile_serializer, :url_for
      end
    end
  end
end
