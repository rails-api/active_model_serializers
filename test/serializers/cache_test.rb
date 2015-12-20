require 'test_helper'
require 'tmpdir'
require 'tempfile'
module ActiveModel
  class Serializer
    class CacheTest < ActiveSupport::TestCase
      include ActiveSupport::Testing::Stream

      def setup
        ActionController::Base.cache_store.clear
        @comment        = Comment.new(id: 1, body: 'ZOMG A COMMENT')
        @post           = Post.new(title: 'New Post', body: 'Body')
        @bio            = Bio.new(id: 1, content: 'AMS Contributor')
        @author         = Author.new(name: 'Joao M. D. Moura')
        @blog           = Blog.new(id: 999, name: 'Custom blog', writer: @author, articles: [])
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
        @blog_serializer     = BlogSerializer.new(@blog)
      end

      def test_inherited_cache_configuration
        inherited_serializer = Class.new(PostSerializer)

        assert_equal PostSerializer._cache_key, inherited_serializer._cache_key
        assert_equal PostSerializer._cache_options, inherited_serializer._cache_options
      end

      def test_override_cache_configuration
        inherited_serializer = Class.new(PostSerializer) do
          cache key: 'new-key'
        end

        assert_equal PostSerializer._cache_key, 'post'
        assert_equal inherited_serializer._cache_key, 'new-key'
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
        render_object_with_cache(@author)
        assert_equal(nil, ActionController::Base.cache_store.fetch(@author.cache_key))
        assert_equal(@author_serializer.attributes.to_json, ActionController::Base.cache_store.fetch("#{@author_serializer.class._cache_key}/#{@author_serializer.object.id}-#{@author_serializer.object.updated_at.strftime("%Y%m%d%H%M%S%9N")}").to_json)
      end

      def test_default_cache_key_fallback
        render_object_with_cache(@comment)
        assert_equal(@comment_serializer.attributes.to_json, ActionController::Base.cache_store.fetch(@comment.cache_key).to_json)
      end

      def test_cache_options_definition
        assert_equal({ expires_in: 0.1, skip_digest: true }, @post_serializer.class._cache_options)
        assert_equal(nil, @blog_serializer.class._cache_options)
        assert_equal({ expires_in: 1.day, skip_digest: true }, @comment_serializer.class._cache_options)
      end

      def test_fragment_cache_definition
        assert_equal([:name], @role_serializer.class._cache_only)
        assert_equal([:content], @bio_serializer.class._cache_except)
      end

      def test_associations_separately_cache
        ActionController::Base.cache_store.clear
        assert_equal(nil, ActionController::Base.cache_store.fetch(@post.cache_key))
        assert_equal(nil, ActionController::Base.cache_store.fetch(@comment.cache_key))

        Timecop.freeze(Time.now) do
          render_object_with_cache(@post)

          assert_equal(@post_serializer.attributes, ActionController::Base.cache_store.fetch(@post.cache_key))
          assert_equal(@comment_serializer.attributes, ActionController::Base.cache_store.fetch(@comment.cache_key))
        end
      end

      def test_associations_cache_when_updated
        # Clean the Cache
        ActionController::Base.cache_store.clear

        Timecop.freeze(Time.now) do
          # Generate a new Cache of Post object and each objects related to it.
          render_object_with_cache(@post)

          # Check if it cached the objects separately
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
        assert_equal({ place: 'Nowhere' }, ActionController::Base.cache_store.fetch(@location.cache_key))
      end

      def test_uses_file_digest_in_cache_key
        render_object_with_cache(@blog)
        assert_equal(@blog_serializer.attributes, ActionController::Base.cache_store.fetch(@blog.cache_key_with_digest))
      end

      def test_cache_digest_definition
        assert_equal(::Model::FILE_DIGEST, @post_serializer.class._cache_digest)
      end

      def test_serializer_file_path_on_nix
        path = '/Users/git/emberjs/ember-crm-backend/app/serializers/lead_serializer.rb'
        caller_line = "#{path}:1:in `<top (required)>'"
        assert_equal caller_line[ActiveModel::Serializer::CALLER_FILE], path
      end

      def test_serializer_file_path_on_windows
        path = 'c:/git/emberjs/ember-crm-backend/app/serializers/lead_serializer.rb'
        caller_line = "#{path}:1:in `<top (required)>'"
        assert_equal caller_line[ActiveModel::Serializer::CALLER_FILE], path
      end

      def test_serializer_file_path_with_space
        path = '/Users/git/ember js/ember-crm-backend/app/serializers/lead_serializer.rb'
        caller_line = "#{path}:1:in `<top (required)>'"
        assert_equal caller_line[ActiveModel::Serializer::CALLER_FILE], path
      end

      def test_serializer_file_path_with_submatch
        # The submatch in the path ensures we're using a correctly greedy regexp.
        path = '/Users/git/ember js/ember:123:in x/app/serializers/lead_serializer.rb'
        caller_line = "#{path}:1:in `<top (required)>'"
        assert_equal caller_line[ActiveModel::Serializer::CALLER_FILE], path
      end

      def test_digest_caller_file
        contents = "puts 'AMS rocks'!"
        dir = Dir.mktmpdir('space char')
        file = Tempfile.new('some_ruby.rb', dir)
        file.write(contents)
        path = file.path
        caller_line = "#{path}:1:in `<top (required)>'"
        file.close
        assert_equal ActiveModel::Serializer.digest_caller_file(caller_line), Digest::MD5.hexdigest(contents)
      ensure
        file.unlink
        FileUtils.remove_entry dir
      end

      def test_warn_on_serializer_not_defined_in_file
        called = false
        serializer = Class.new(ActiveModel::Serializer)
        assert_match(/_cache_digest/, (capture(:stderr) do
          serializer.digest_caller_file('')
          called = true
        end))
        assert called
      end

      private

      def render_object_with_cache(obj)
        ActiveModel::SerializableResource.new(obj).serializable_hash
      end
    end
  end
end

