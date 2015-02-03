require 'test_helper'
module ActiveModel
  class Serializer
    class CacheTest < Minitest::Test
      def setup
        ActionController::Base.cache_store.clear
        @comment        = Comment.new(id: 1, body: 'ZOMG A COMMENT')
        @blog           = Blog.new(id: 999, name: "Custom blog")
        @post           = Post.new(title: 'New Post', body: 'Body')
        @bio            = Bio.new(id: 1, content: 'AMS Contributor')
        @author         = Author.new(name: 'Joao M. D. Moura')
        @role           = Role.new(name: 'Great Author')
        @location       = Location.new(lat: '-23.550520', lng: '-46.633309')
        @place          = Place.new(name: 'Amazing Place')
        @author.posts   = [@post]
        @author.roles   = [@role]
        @role.author    = @author
        @author.bio     = @bio
        @bio.author     = @author
        @post.comments  = [@comment]
        @post.author    = @author
        @comment.post   = @post
        @comment.author = @author
        @post.blog      = @blog
        @location.place = @place

        @location_serializer = LocationSerializer.new(@location)
        @bio_serializer      = BioSerializer.new(@bio)
        @role_serializer     = RoleSerializer.new(@role)
        @post_serializer     = PostSerializer.new(@post)
        @author_serializer   = AuthorSerializer.new(@author)
        @comment_serializer  = CommentSerializer.new(@comment)
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
        author = render_object_with_cache(@author)
        assert_equal(nil, ActionController::Base.cache_store.fetch(@author.cache_key))
        assert_equal(@author_serializer.attributes.to_json, ActionController::Base.cache_store.fetch("#{@author_serializer.class._cache_key}/#{@author_serializer.object.id}-#{@author_serializer.object.updated_at}").to_json)
      end

      def test_default_cache_key_fallback
        comment = render_object_with_cache(@comment)
        assert_equal(@comment_serializer.attributes.to_json, ActionController::Base.cache_store.fetch(@comment.cache_key).to_json)
      end

      def test_cache_options_definition
        assert_equal({expires_in: 0.1}, @post_serializer.class._cache_options)
        assert_equal(nil, @author_serializer.class._cache_options)
        assert_equal({expires_in: 1.day}, @comment_serializer.class._cache_options)
      end

      def test_fragment_cache_definition
        assert_equal([:name], @role_serializer.class._cache_only)
        assert_equal([:content], @bio_serializer.class._cache_except)
      end

      def test_associations_separately_cache
        ActionController::Base.cache_store.clear
        assert_equal(nil, ActionController::Base.cache_store.fetch(@post.cache_key))
        assert_equal(nil, ActionController::Base.cache_store.fetch(@comment.cache_key))

        post = render_object_with_cache(@post)

        assert_equal(@post_serializer.attributes, ActionController::Base.cache_store.fetch(@post.cache_key))
        assert_equal(@comment_serializer.attributes, ActionController::Base.cache_store.fetch(@comment.cache_key))
      end

      def test_associations_cache_when_updated
        # Clean the Cache
        ActionController::Base.cache_store.clear

        # Generate a new Cache of Post object and each objects related to it.
        render_object_with_cache(@post)

        # Check if if cache the objects separately
        assert_equal(@post_serializer.attributes, ActionController::Base.cache_store.fetch(@post.cache_key))
        assert_equal(@comment_serializer.attributes, ActionController::Base.cache_store.fetch(@comment.cache_key))

        # Simulating update on comments relationship with Post
        new_comment            = Comment.new(id: 2, body: 'ZOMG A NEW COMMENT')
        new_comment_serializer = CommentSerializer.new(new_comment)
        @post.comments         = [new_comment]

        # Ask for the serialized object
        render_object_with_cache(@post)

        # Check if the the new comment was cached
        assert_equal(new_comment_serializer.attributes, ActionController::Base.cache_store.fetch(new_comment.cache_key))
        assert_equal(@post_serializer.attributes, ActionController::Base.cache_store.fetch(@post.cache_key))
      end

      def test_fragment_fetch_with_virtual_associations
        expected_result = {
          id: @location.id,
          lat: @location.lat,
          lng: @location.lng,
          place: 'Nowhere'
        }

        hash = render_object_with_cache(@location)

        assert_equal(hash, expected_result)
        assert_equal({place: 'Nowhere'}, ActionController::Base.cache_store.fetch(@location.cache_key))
      end

      private
      def render_object_with_cache(obj)
        serializer_class = ActiveModel::Serializer.serializer_for(obj)
        serializer = serializer_class.new(obj)
        adapter = ActiveModel::Serializer.adapter.new(serializer)
        adapter.serializable_hash
      end
    end
  end
end

