require 'test_helper'

module ActiveModel
  class Serializer
    class UrlsTest < Minitest::Test

      def setup
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @post = Post.new({ title: 'New Post', body: 'Body' })
        @comment = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
        @post.comments = [@comment]

        @profile_serializer = ProfileSerializer.new(@profile)
        @post_serializer = PostSerializer.new(@post)
      end

      def test_urls_definition
        assert_equal([:posts, :comments], @profile_serializer.class._urls)
      end

      def test_url_definition
        assert_equal([:comments], @post_serializer.class._urls)
      end
    end
  end
end
