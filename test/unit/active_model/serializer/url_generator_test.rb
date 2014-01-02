require 'test_helper'

module ActiveModel
  class Serializer
    class UrlGeneratorTest < ActiveModel::TestCase
      def setup
        @post = Post.new(title: 'Hi', body: 'How are you?')
        @url_generator = UrlGenerator.new(host: 'example.com')
      end

      def test_url_generator_available
        serializer = PostSerializer.new(@post, url_generator: @url_generator)

        assert_equal(@url_generator, serializer.url_generator)
      end

      def test_url_generator_available_in_associations
        category = Category.new(name: 'Welcome', posts: [@post])
        serializer = CategorySerializer.new(category, url_generator: @url_generator)
        serialized_post = serializer.associations[:posts].first

        assert_equal('http://example.com/post', serialized_post[:link])
      end
    end
  end
end

