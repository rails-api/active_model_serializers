require 'test_helper'
module ActiveModel
  class Serializer
    class CacheTest < Minitest::Test
      def setup
        @post            = Post.new({ title: 'New Post', body: 'Body' })
        @comment         = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
        @author          = Author.new(name: 'Joao M. D. Moura')
        @role            = Role.new(name: 'Great Author')
        @author.posts    = [@post]
        @author.roles    = [@role]
        @author.bio      = nil
        @post.comments   = [@comment]
        @post.author     = @author
        @comment.post    = @post
        @comment.author  = @author

        @post_serializer    = PostSerializer.new(@post)
        @author_serializer  = AuthorSerializer.new(@author)
        @comment_serializer = CommentSerializer.new(@comment)
      end

      def test_cache_definition
        assert_equal(ActionController::Base.cache_store, @post_serializer.class._cache)
        assert_equal(ActionController::Base.cache_store, @author_serializer.class._cache)
        assert_equal(ActionController::Base.cache_store, @comment_serializer.class._cache)
      end

      def test_cache_key_definition
        assert_equal('post', @post_serializer.class._cache_key)
        assert_equal('writer', @author_serializer.class._cache_key)
        assert_equal(nil, @comment_serializer.class._cache_key)
      end

      def test_cache_key_interpolation_with_updated_at
        author = render_object_with_cache_without_cache_key(@author)
        assert_equal(nil, ActionController::Base.cache_store.fetch(@author.cache_key))
        assert_equal(author, ActionController::Base.cache_store.fetch("#{@author_serializer.class._cache_key}/#{@author_serializer.object.id}-#{@author_serializer.object.updated_at}").to_json)
      end

      def test_default_cache_key_fallback
        comment = render_object_with_cache_without_cache_key(@comment)
        assert_equal(comment, ActionController::Base.cache_store.fetch(@comment.cache_key).to_json)
      end

      def test_cache_options_definition
        assert_equal({expires_in: 0.05}, @post_serializer.class._cache_options)
        assert_equal(nil, @author_serializer.class._cache_options)
        assert_equal({expires_in: 1.day}, @comment_serializer.class._cache_options)
      end

      private
      def render_object_with_cache_without_cache_key(obj)
        serializer_class = ActiveModel::Serializer.serializer_for(obj)
        serializer = serializer_class.new(obj)
        adapter = ActiveModel::Serializer.adapter.new(serializer)
        adapter.to_json
      end
    end
  end
end

