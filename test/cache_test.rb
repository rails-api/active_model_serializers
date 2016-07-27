require 'test_helper'
require 'tmpdir'
require 'tempfile'

module ActiveModelSerializers
  class CacheTest < ActiveSupport::TestCase
    class UncachedAuthor < Author
      # To confirm cache_key is set using updated_at and cache_key option passed to cache
      undef_method :cache_key
    end

    class Article < ::Model
      # To confirm error is raised when cache_key is not set and cache_key option not passed to cache
      undef_method :cache_key
    end

    class ArticleSerializer < ActiveModel::Serializer
      cache only: [:place], skip_digest: true
      attributes :title
    end

    class InheritedRoleSerializer < RoleSerializer
      cache key: 'inherited_role', only: [:name, :special_attribute]
      attribute :special_attribute
    end

    setup do
      cache_store.clear
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

    test 'explicit_cache_store' do
      default_store = Class.new(ActiveModel::Serializer) do
        cache
      end
      explicit_store = Class.new(ActiveModel::Serializer) do
        cache cache_store: ActiveSupport::Cache::FileStore
      end

      assert ActiveSupport::Cache::MemoryStore, ActiveModelSerializers.config.cache_store
      assert ActiveSupport::Cache::MemoryStore, default_store.cache_store
      assert ActiveSupport::Cache::FileStore, explicit_store.cache_store
    end

    test 'inherited_cache_configuration' do
      inherited_serializer = Class.new(PostSerializer)

      assert_equal PostSerializer._cache_key, inherited_serializer._cache_key
      assert_equal PostSerializer._cache_options, inherited_serializer._cache_options
    end

    test 'override_cache_configuration' do
      inherited_serializer = Class.new(PostSerializer) do
        cache key: 'new-key'
      end

      assert_equal PostSerializer._cache_key, 'post'
      assert_equal inherited_serializer._cache_key, 'new-key'
    end

    test 'cache_definition' do
      assert_equal(cache_store, @post_serializer.class._cache)
      assert_equal(cache_store, @author_serializer.class._cache)
      assert_equal(cache_store, @comment_serializer.class._cache)
    end

    test 'cache_key_definition' do
      assert_equal('post', @post_serializer.class._cache_key)
      assert_equal('writer', @author_serializer.class._cache_key)
      assert_equal(nil, @comment_serializer.class._cache_key)
    end

    test 'cache_key_interpolation_with_updated_at_when_cache_key_is_not_defined_on_object' do
      uncached_author            = UncachedAuthor.new(name: 'Joao M. D. Moura')
      uncached_author_serializer = AuthorSerializer.new(uncached_author)

      render_object_with_cache(uncached_author)
      key = "#{uncached_author_serializer.class._cache_key}/#{uncached_author_serializer.object.id}-#{uncached_author_serializer.object.updated_at.strftime('%Y%m%d%H%M%S%9N')}"
      key = "#{key}/#{adapter.cache_key}"
      assert_equal(uncached_author_serializer.attributes.to_json, cache_store.fetch(key).to_json)
    end

    test 'default_cache_key_fallback' do
      render_object_with_cache(@comment)
      key = "#{@comment.cache_key}/#{adapter.cache_key}"
      assert_equal(@comment_serializer.attributes.to_json, cache_store.fetch(key).to_json)
    end

    test 'error_is_raised_if_cache_key_is_not_defined_on_object_or_passed_as_cache_option' do
      article = Article.new(title: 'Must Read')
      e = assert_raises ActiveModel::Serializer::UndefinedCacheKey do
        render_object_with_cache(article)
      end
      assert_match(/ActiveModelSerializers::CacheTest::Article must define #cache_key, or the 'key:' option must be passed into 'ActiveModelSerializers::CacheTest::ArticleSerializer.cache'/, e.message)
    end

    test 'cache_options_definition' do
      assert_equal({ expires_in: 0.1, skip_digest: true }, @post_serializer.class._cache_options)
      assert_equal(nil, @blog_serializer.class._cache_options)
      assert_equal({ expires_in: 1.day, skip_digest: true }, @comment_serializer.class._cache_options)
    end

    test 'fragment_cache_definition' do
      assert_equal([:name, :slug], @role_serializer.class._cache_only)
      assert_equal([:content], @bio_serializer.class._cache_except)
    end

    test 'associations_separately_cache' do
      cache_store.clear
      assert_equal(nil, cache_store.fetch(@post.cache_key))
      assert_equal(nil, cache_store.fetch(@comment.cache_key))

      Timecop.freeze(Time.current) do
        render_object_with_cache(@post)

        key = "#{@post.cache_key}/#{adapter.cache_key}"
        assert_equal(@post_serializer.attributes, cache_store.fetch(key))
        key = "#{@comment.cache_key}/#{adapter.cache_key}"
        assert_equal(@comment_serializer.attributes, cache_store.fetch(key))
      end
    end

    test 'associations_cache_when_updated' do
      Timecop.freeze(Time.current) do
        # Generate a new Cache of Post object and each objects related to it.
        render_object_with_cache(@post)

        # Check if it cached the objects separately
        key = "#{@post.cache_key}/#{adapter.cache_key}"
        assert_equal(@post_serializer.attributes, cache_store.fetch(key))
        key = "#{@comment.cache_key}/#{adapter.cache_key}"
        assert_equal(@comment_serializer.attributes, cache_store.fetch(key))

        # Simulating update on comments relationship with Post
        new_comment            = Comment.new(id: 2567, body: 'ZOMG A NEW COMMENT')
        new_comment_serializer = CommentSerializer.new(new_comment)
        @post.comments         = [new_comment]

        # Ask for the serialized object
        render_object_with_cache(@post)

        # Check if the the new comment was cached
        key = "#{new_comment.cache_key}/#{adapter.cache_key}"
        assert_equal(new_comment_serializer.attributes, cache_store.fetch(key))
        key = "#{@post.cache_key}/#{adapter.cache_key}"
        assert_equal(@post_serializer.attributes, cache_store.fetch(key))
      end
    end

    test 'fragment_fetch_with_virtual_associations' do
      expected_result = {
        id: @location.id,
        lat: @location.lat,
        lng: @location.lng,
        address: 'Nowhere'
      }

      hash = render_object_with_cache(@location)

      assert_equal(hash, expected_result)
      key = "#{@location.cache_key}/#{adapter.cache_key}"
      assert_equal({ address: 'Nowhere' }, cache_store.fetch(key))
    end

    test 'fragment_cache_with_inheritance' do
      inherited = render_object_with_cache(@role, serializer: InheritedRoleSerializer)
      base = render_object_with_cache(@role)

      assert_includes(inherited.keys, :special_attribute)
      refute_includes(base.keys, :special_attribute)
    end

    test 'uses_adapter_in_cache_key' do
      render_object_with_cache(@post)
      key = "#{@post.cache_key}/#{adapter.class.to_s.demodulize.underscore}"
      assert_equal(@post_serializer.attributes, cache_store.fetch(key))
    end

    # Based on original failing test by @kevintyll
    # rubocop:disable Metrics/AbcSize
    test 'a_serializer_rendered_by_two_adapter_returns_differently_fetch_attributes' do
      begin
        Object.const_set(:Alert, Class.new(ActiveModelSerializers::Model) do
          attr_accessor :id, :status, :resource, :started_at, :ended_at, :updated_at, :created_at
        end)
        Object.const_set(:UncachedAlertSerializer, Class.new(ActiveModel::Serializer) do
          attributes :id, :status, :resource, :started_at, :ended_at, :updated_at, :created_at
        end)
        Object.const_set(:AlertSerializer, Class.new(UncachedAlertSerializer) do
          cache
        end)

        alert = Alert.new(
          id: 1,
          status: 'fail',
          resource: 'resource-1',
          started_at: Time.new(2016, 3, 31, 21, 36, 35, 0),
          ended_at: nil,
          updated_at: Time.new(2016, 3, 31, 21, 27, 35, 0),
          created_at: Time.new(2016, 3, 31, 21, 37, 35, 0)
        )

        expected_fetch_attributes = {
          id: 1,
          status: 'fail',
          resource: 'resource-1',
          started_at: alert.started_at,
          ended_at: nil,
          updated_at: alert.updated_at,
          created_at: alert.created_at
        }
        expected_cached_jsonapi_attributes = {
          id: '1',
          type: 'alerts',
          attributes: {
            status: 'fail',
            resource: 'resource-1',
            started_at: alert.started_at,
            ended_at: nil,
            updated_at: alert.updated_at,
            created_at: alert.created_at
          }
        }

        # Assert attributes are serialized correctly
        serializable_alert = serializable(alert, serializer: AlertSerializer, adapter: :attributes)
        attributes_serialization = serializable_alert.as_json
        assert_equal expected_fetch_attributes, alert.attributes
        assert_equal alert.attributes, attributes_serialization
        attributes_cache_key = serializable_alert.adapter.serializer.cache_key(serializable_alert.adapter)
        assert_equal attributes_serialization, cache_store.fetch(attributes_cache_key)

        serializable_alert = serializable(alert, serializer: AlertSerializer, adapter: :json_api)
        jsonapi_cache_key = serializable_alert.adapter.serializer.cache_key(serializable_alert.adapter)
        # Assert cache keys differ
        refute_equal attributes_cache_key, jsonapi_cache_key
        # Assert (cached) serializations differ
        jsonapi_serialization = serializable_alert.as_json
        assert_equal alert.status, jsonapi_serialization.fetch(:data).fetch(:attributes).fetch(:status)
        serializable_alert = serializable(alert, serializer: UncachedAlertSerializer, adapter: :json_api)
        assert_equal serializable_alert.as_json, jsonapi_serialization

        cached_serialization = cache_store.fetch(jsonapi_cache_key)
        assert_equal expected_cached_jsonapi_attributes, cached_serialization
      ensure
        Object.send(:remove_const, :Alert)
        Object.send(:remove_const, :AlertSerializer)
        Object.send(:remove_const, :UncachedAlertSerializer)
      end
    end
    # rubocop:enable Metrics/AbcSize

    test 'uses_file_digest_in_cache_key' do
      render_object_with_cache(@blog)
      key = "#{@blog.cache_key}/#{adapter.cache_key}/#{::Model::FILE_DIGEST}"
      assert_equal(@blog_serializer.attributes, cache_store.fetch(key))
    end

    test 'cache_digest_definition' do
      assert_equal(::Model::FILE_DIGEST, @post_serializer.class._cache_digest)
    end

    test 'object_cache_keys' do
      serializable = ActiveModelSerializers::SerializableResource.new([@comment, @comment])
      include_directive = JSONAPI::IncludeDirective.new('*', allow_wildcard: true)

      actual = ActiveModel::Serializer.object_cache_keys(serializable.adapter.serializer, serializable.adapter, include_directive)

      assert_equal 3, actual.size
      assert actual.any? { |key| key == "comment/1/#{serializable.adapter.cache_key}" }
      assert actual.any? { |key| key =~ %r{post/post-\d+} }
      assert actual.any? { |key| key =~ %r{author/author-\d+} }
    end

    test 'fetch_attributes_from_cache' do
      serializers = ActiveModel::Serializer::CollectionSerializer.new([@comment, @comment])

      Timecop.freeze(Time.current) do
        render_object_with_cache(@comment)

        options = {}
        adapter_options = {}
        adapter_instance = ActiveModelSerializers::Adapter::Attributes.new(serializers, adapter_options)
        serializers.serializable_hash(adapter_options, options, adapter_instance)
        cached_attributes = adapter_options.fetch(:cached_attributes)

        include_directive = ActiveModelSerializers.default_include_directive
        manual_cached_attributes = ActiveModel::Serializer.cache_read_multi(serializers, adapter_instance, include_directive)
        assert_equal manual_cached_attributes, cached_attributes

        assert_equal cached_attributes["#{@comment.cache_key}/#{adapter_instance.cache_key}"], Comment.new(id: 1, body: 'ZOMG A COMMENT').attributes
        assert_equal cached_attributes["#{@comment.post.cache_key}/#{adapter_instance.cache_key}"], Post.new(id: 'post', title: 'New Post', body: 'Body').attributes

        writer = @comment.post.blog.writer
        writer_cache_key = writer.cache_key
        assert_equal cached_attributes["#{writer_cache_key}/#{adapter_instance.cache_key}"], Author.new(id: 'author', name: 'Joao M. D. Moura').attributes
      end
    end

    test 'cache_read_multi_with_fragment_cache_enabled' do
      post_serializer = Class.new(ActiveModel::Serializer) do
        cache except: [:body]
      end

      serializers = ActiveModel::Serializer::CollectionSerializer.new([@post, @post], serializer: post_serializer)

      Timecop.freeze(Time.current) do
        # Warming up.
        options = {}
        adapter_options = {}
        adapter_instance = ActiveModelSerializers::Adapter::Attributes.new(serializers, adapter_options)
        serializers.serializable_hash(adapter_options, options, adapter_instance)

        # Should find something with read_multi now
        adapter_options = {}
        serializers.serializable_hash(adapter_options, options, adapter_instance)
        cached_attributes = adapter_options.fetch(:cached_attributes)

        include_directive = ActiveModelSerializers.default_include_directive
        manual_cached_attributes = ActiveModel::Serializer.cache_read_multi(serializers, adapter_instance, include_directive)

        refute_equal 0, cached_attributes.size
        refute_equal 0, manual_cached_attributes.size
        assert_equal manual_cached_attributes, cached_attributes
      end
    end

    test 'serializer_file_path_on_nix' do
      path = '/Users/git/emberjs/ember-crm-backend/app/serializers/lead_serializer.rb'
      caller_line = "#{path}:1:in `<top (required)>'"
      assert_equal caller_line[ActiveModel::Serializer::CALLER_FILE], path
    end

    test 'serializer_file_path_on_windows' do
      path = 'c:/git/emberjs/ember-crm-backend/app/serializers/lead_serializer.rb'
      caller_line = "#{path}:1:in `<top (required)>'"
      assert_equal caller_line[ActiveModel::Serializer::CALLER_FILE], path
    end

    test 'serializer_file_path_with_space' do
      path = '/Users/git/ember js/ember-crm-backend/app/serializers/lead_serializer.rb'
      caller_line = "#{path}:1:in `<top (required)>'"
      assert_equal caller_line[ActiveModel::Serializer::CALLER_FILE], path
    end

    test 'serializer_file_path_with_submatch' do
      # The submatch in the path ensures we're using a correctly greedy regexp.
      path = '/Users/git/ember js/ember:123:in x/app/serializers/lead_serializer.rb'
      caller_line = "#{path}:1:in `<top (required)>'"
      assert_equal caller_line[ActiveModel::Serializer::CALLER_FILE], path
    end

    test 'digest_caller_file' do
      begin
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
    end

    test 'warn_on_serializer_not_defined_in_file' do
      called = false
      serializer = Class.new(ActiveModel::Serializer)
      assert_output(nil, /_cache_digest/) do
        serializer.digest_caller_file('')
        called = true
      end
      assert called
    end

    test 'cached_false_without_cache_store' do
      cached_serializer = build_cached_serializer do |serializer|
        serializer._cache = nil
      end
      refute cached_serializer.class.cache_enabled?
    end

    test 'cached_true_with_cache_store_and_without_cache_only_and_cache_except' do
      cached_serializer = build_cached_serializer do |serializer|
        serializer._cache = Object
      end
      assert cached_serializer.class.cache_enabled?
    end

    test 'cached_false_with_cache_store_and_with_cache_only' do
      cached_serializer = build_cached_serializer do |serializer|
        serializer._cache = Object
        serializer._cache_only = [:name]
      end
      refute cached_serializer.class.cache_enabled?
    end

    test 'cached_false_with_cache_store_and_with_cache_except' do
      cached_serializer = build_cached_serializer do |serializer|
        serializer._cache = Object
        serializer._cache_except = [:content]
      end
      refute cached_serializer.class.cache_enabled?
    end

    test 'fragment_cached_false_without_cache_store' do
      cached_serializer = build_cached_serializer do |serializer|
        serializer._cache = nil
        serializer._cache_only = [:name]
      end
      refute cached_serializer.class.fragment_cache_enabled?
    end

    test 'fragment_cached_true_with_cache_store_and_cache_only' do
      cached_serializer = build_cached_serializer do |serializer|
        serializer._cache = Object
        serializer._cache_only = [:name]
      end
      assert cached_serializer.class.fragment_cache_enabled?
    end

    test 'fragment_cached_true_with_cache_store_and_cache_except' do
      cached_serializer = build_cached_serializer do |serializer|
        serializer._cache = Object
        serializer._cache_except = [:content]
      end
      assert cached_serializer.class.fragment_cache_enabled?
    end

    test 'fragment_cached_false_with_cache_store_and_cache_except_and_cache_only' do
      cached_serializer = build_cached_serializer do |serializer|
        serializer._cache = Object
        serializer._cache_except = [:content]
        serializer._cache_only = [:name]
      end
      refute cached_serializer.class.fragment_cache_enabled?
    end

    test 'fragment_fetch_with_virtual_attributes' do
      author          = Author.new(name: 'Joao M. D. Moura')
      role            = Role.new(name: 'Great Author', description: nil)
      role.author     = [author]
      role_serializer = RoleSerializer.new(role)
      adapter_instance = ActiveModelSerializers::Adapter.configured_adapter.new(role_serializer)
      expected_result = {
        id: role.id,
        description: role.description,
        slug: "#{role.name}-#{role.id}",
        name: role.name
      }
      cache_store.clear

      role_hash = role_serializer.fetch_attributes_fragment(adapter_instance)
      assert_equal(role_hash, expected_result)

      role.attributes[:id] = 'this has been updated'
      role.name = 'this was cached'

      role_hash = role_serializer.fetch_attributes_fragment(adapter_instance)
      assert_equal(expected_result.merge(id: role.id), role_hash)
    end

    test 'fragment_fetch_with_except' do
      adapter_instance = ActiveModelSerializers::Adapter.configured_adapter.new(@bio_serializer)
      expected_result = {
        id: @bio.id,
        rating: nil,
        content: @bio.content
      }
      cache_store.clear

      bio_hash = @bio_serializer.fetch_attributes_fragment(adapter_instance)
      assert_equal(expected_result, bio_hash)

      @bio.content = 'this has been updated'
      @bio.rating = 'this was cached'

      bio_hash = @bio_serializer.fetch_attributes_fragment(adapter_instance)
      assert_equal(expected_result.merge(content: @bio.content), bio_hash)
    end

    test 'fragment_fetch_with_namespaced_object' do
      @spam            = Spam::UnrelatedLink.new(id: 'spam-id-1')
      @spam_serializer = Spam::UnrelatedLinkSerializer.new(@spam)
      adapter_instance = ActiveModelSerializers::Adapter.configured_adapter.new(@spam_serializer)
      @spam_hash       = @spam_serializer.fetch_attributes_fragment(adapter_instance)
      expected_result = {
        id: @spam.id
      }
      assert_equal(@spam_hash, expected_result)
    end

    private

    def cache_store
      ActiveModelSerializers.config.cache_store
    end

    def build_cached_serializer
      serializer = Class.new(ActiveModel::Serializer)
      serializer._cache_key = nil
      serializer._cache_options = nil
      yield serializer if block_given?
      serializer.new(Object)
    end

    def render_object_with_cache(obj, options = {})
      @serializable_resource = serializable(obj, options)
      @serializable_resource.serializable_hash
    end

    def adapter
      @serializable_resource.adapter
    end
  end
end
