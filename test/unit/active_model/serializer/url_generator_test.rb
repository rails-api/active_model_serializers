require 'test_helper'

module ActiveModel
  class Serializer
    class UrlGeneratorTest < ActiveModel::TestCase
      def setup
        @post = Post.new(title: 'Hi', body: 'How are you?')
        @url_generator = UrlGenerator.new(host: 'example.com')
      end

      def test_url_generator_available
        serializer = HypermediaPostSerializer.new(@post, url_generator: @url_generator)
        serialized_post = serializer.as_json['hypermedia_post']

        assert_equal(@url_generator, serializer.url_generator)
        assert_equal('http://example.com/post', serialized_post[:link])
      end

      def test_url_generator_available_in_associations
        category = Category.new(name: 'Welcome', posts: [@post])
        serializer = CategorySerializer.new(category, url_generator: @url_generator)
        serialized_post = serializer.associations[:posts].first

        assert_equal('http://example.com/post', serialized_post[:link])
      end
    end

    class UrlGeneratorDefaultsTest < ActiveModel::TestCase
      def setup
        @post = Post.new(title: 'Hi', body: 'How are you?')
        @old_url_options = CONFIG.default_url_options
        @url_generator = UrlGenerator.new
      end

      def test_url_generator_uses_default_url_options_from_config
        CONFIG.default_url_options = {host: 'default.local'}
        serializer = HypermediaPostSerializer.new(@post, url_generator: @url_generator)
        serialized_post = serializer.as_json['hypermedia_post']

        assert_equal('http://default.local/post', serialized_post[:link])
      end

      def teardown
        CONFIG.default_url_options = @old_url_options
      end
    end
  end
end

