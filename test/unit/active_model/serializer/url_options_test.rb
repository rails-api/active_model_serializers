require 'test_helper'

module ActiveModel
  class Serializer
    class UrlOptionsTest < ActiveModel::TestCase
      def setup
        @post = Post.new(title: 'Hi', body: 'How are you?')
      end

      def test_url_options_available
        serializer = PostSerializer.new(@post, url_options: { host: 'example.com' })

        assert_equal({ host: 'example.com' }, serializer.url_options)
      end

      def test_url_options_available_in_associations
        category = Category.new(name: 'Welcome', posts: [@post])
        serializer = CategorySerializer.new(category, url_options: { host: 'example.com' })
        serialized_post = serializer.associations[:posts].first

        assert_equal(serialized_post[:link], 'http://example.com/post')
      end
    end
  end
end

