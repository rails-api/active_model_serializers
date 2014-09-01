require 'test_helper'

module ActiveModel
  class Serializer
    class UrlsTest < Minitest::Test

      def setup
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        ProfileSerializer.class_eval do
          urls :posts, :comments
        end

        @profile_serializer = ProfileSerializer.new(@post)
      end

      def test_urls_definition
        assert_equal([:posts, :comments], @profile_serializer.class._urls)
      end
    end
  end
end

