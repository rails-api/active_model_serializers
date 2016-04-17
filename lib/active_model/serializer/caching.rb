module ActiveModel
  class Serializer
    UndefinedCacheKey = Class.new(StandardError)
    module Caching
      extend ActiveSupport::Concern

      included do
        with_options instance_writer: false, instance_reader: false do |serializer|
          serializer.class_attribute :_cache         # @api private : the cache store
          serializer.class_attribute :_fragmented    # @api private : @see ::fragmented
          serializer.class_attribute :_cache_key     # @api private : when present, is first item in cache_key.  Ignored if the serializable object defines #cache_key.
          serializer.class_attribute :_cache_only    # @api private : when fragment caching, whitelists cached_attributes. Cannot combine with except
          serializer.class_attribute :_cache_except  # @api private : when fragment caching, blacklists cached_attributes. Cannot combine with only
          serializer.class_attribute :_cache_options # @api private : used by CachedSerializer, passed to _cache.fetch
          #  _cache_options include:
          #    expires_in
          #    compress
          #    force
          #    race_condition_ttl
          #  Passed to ::_cache as
          #    serializer.cache_store.fetch(cache_key, @klass._cache_options)
          #  Passed as second argument to serializer.cache_store.fetch(cache_key, self.class._cache_options)
          serializer.class_attribute :_cache_digest_file_path # @api private : Derived at inheritance
        end
      end

      # Matches
      #  "c:/git/emberjs/ember-crm-backend/app/serializers/lead_serializer.rb:1:in `<top (required)>'"
      #  AND
      #  "/c/git/emberjs/ember-crm-backend/app/serializers/lead_serializer.rb:1:in `<top (required)>'"
      #  AS
      #  c/git/emberjs/ember-crm-backend/app/serializers/lead_serializer.rb
      CALLER_FILE = /
        \A       # start of string
        .+       # file path (one or more characters)
        (?=      # stop previous match when
          :\d+     # a colon is followed by one or more digits
          :in      # followed by a colon followed by in
        )
      /x

      module ClassMethods
        def inherited(base)
          super
          caller_line = caller[1]
          base._cache_digest_file_path = caller_line
        end

        def _cache_digest
          return @_cache_digest if defined?(@_cache_digest)
          @_cache_digest = digest_caller_file(_cache_digest_file_path)
        end

        # Hashes contents of file for +_cache_digest+
        def digest_caller_file(caller_line)
          serializer_file_path = caller_line[CALLER_FILE]
          serializer_file_contents = IO.read(serializer_file_path)
          Digest::MD5.hexdigest(serializer_file_contents)
        rescue TypeError, Errno::ENOENT
          warn <<-EOF.strip_heredoc
            Cannot digest non-existent file: '#{caller_line}'.
            Please set `::_cache_digest` of the serializer
            if you'd like to cache it.
            EOF
          ''.freeze
        end

        def _skip_digest?
          _cache_options && _cache_options[:skip_digest]
        end

        def cached_attributes
          _cache_only ? _cache_only : _attributes - _cache_except
        end

        def non_cached_attributes
          _attributes - cached_attributes
        end

        # @api private
        # Used by FragmentCache on the CachedSerializer
        #  to call attribute methods on the fragmented cached serializer.
        def fragmented(serializer)
          self._fragmented = serializer
        end

        # Enables a serializer to be automatically cached
        #
        # Sets +::_cache+ object to <tt>ActionController::Base.cache_store</tt>
        #   when Rails.configuration.action_controller.perform_caching
        #
        # @param options [Hash] with valid keys:
        #   cache_store    : @see ::_cache
        #   key            : @see ::_cache_key
        #   only           : @see ::_cache_only
        #   except         : @see ::_cache_except
        #   skip_digest    : does not include digest in cache_key
        #   all else       : @see ::_cache_options
        #
        # @example
        #   class PostSerializer < ActiveModel::Serializer
        #     cache key: 'post', expires_in: 3.hours
        #     attributes :title, :body
        #
        #     has_many :comments
        #   end
        #
        # @todo require less code comments. See
        # https://github.com/rails-api/active_model_serializers/pull/1249#issuecomment-146567837
        def cache(options = {})
          self._cache =
            options.delete(:cache_store) ||
            ActiveModelSerializers.config.cache_store ||
            ActiveSupport::Cache.lookup_store(:null_store)
          self._cache_key = options.delete(:key)
          self._cache_only = options.delete(:only)
          self._cache_except = options.delete(:except)
          self._cache_options = options.empty? ? nil : options
        end

        # Value is from ActiveModelSerializers.config.perform_caching. Is used to
        # globally enable or disable all serializer caching, just like
        # Rails.configuration.action_controller.perform_caching, which is its
        # default value in a Rails application.
        # @return [true, false]
        # Memoizes value of config first time it is called with a non-nil value.
        # rubocop:disable Style/ClassVars
        def perform_caching
          return @@perform_caching if defined?(@@perform_caching) && !@@perform_caching.nil?
          @@perform_caching = ActiveModelSerializers.config.perform_caching
        end
        alias perform_caching? perform_caching
        # rubocop:enable Style/ClassVars

        # The canonical method for getting the cache store for the serializer.
        #
        # @return [nil] when _cache is not set (i.e. when `cache` has not been called)
        # @return [._cache] when _cache is not the NullStore
        # @return [ActiveModelSerializers.config.cache_store] when _cache is the NullStore.
        #   This is so we can use `cache` being called to mean the serializer should be cached
        #   even if ActiveModelSerializers.config.cache_store has not yet been set.
        #   That means that when _cache is the NullStore and ActiveModelSerializers.config.cache_store
        #   is configured, `cache_store` becomes `ActiveModelSerializers.config.cache_store`.
        # @return [nil] when _cache is the NullStore and ActiveModelSerializers.config.cache_store is nil.
        def cache_store
          return nil if _cache.nil?
          return _cache if _cache.class != ActiveSupport::Cache::NullStore
          if ActiveModelSerializers.config.cache_store
            self._cache = ActiveModelSerializers.config.cache_store
          else
            nil
          end
        end

        def cache_enabled?
          perform_caching? && cache_store && !_cache_only && !_cache_except
        end

        def fragment_cache_enabled?
          perform_caching? && cache_store &&
            (_cache_only && !_cache_except || !_cache_only && _cache_except)
        end

        # Read cache from cache_store
        # @return [Hash]
        def cache_read_multi(collection_serializer, adapter_instance, include_tree)
          return {} if ActiveModelSerializers.config.cache_store.blank?

          keys = object_cache_keys(collection_serializer, adapter_instance, include_tree)

          return {} if keys.blank?

          ActiveModelSerializers.config.cache_store.read_multi(*keys)
        end

        # Find all cache_key for the collection_serializer
        # @param serializers [ActiveModel::Serializer::CollectionSerializer]
        # @param adapter_instance [ActiveModelSerializers::Adapter::Base]
        # @param include_tree [ActiveModel::Serializer::IncludeTree]
        # @return [Array] all cache_key of collection_serializer
        def object_cache_keys(collection_serializer, adapter_instance, include_tree)
          cache_keys = []

          collection_serializer.each do |serializer|
            cache_keys << object_cache_key(serializer, adapter_instance)

            serializer.associations(include_tree).each do |association|
              if association.serializer.respond_to?(:each)
                association.serializer.each do |sub_serializer|
                  cache_keys << object_cache_key(sub_serializer, adapter_instance)
                end
              else
                cache_keys << object_cache_key(association.serializer, adapter_instance)
              end
            end
          end

          cache_keys.compact.uniq
        end

        # @return [String, nil] the cache_key of the serializer or nil
        def object_cache_key(serializer, adapter_instance)
          return unless serializer.present? && serializer.object.present?

          serializer.class.cache_enabled? ? serializer.cache_key(adapter_instance) : nil
        end
      end

      # Get attributes from @cached_attributes
      # @return [Hash] cached attributes
      # def cached_attributes(fields, adapter_instance)
      def cached_fields(fields, adapter_instance)
        cache_check(adapter_instance) do
          attributes(fields)
        end
      end

      def cache_check(adapter_instance)
        if self.class.cache_enabled?
          self.class.cache_store.fetch(cache_key(adapter_instance), self.class._cache_options) do
            yield
          end
        elsif self.class.fragment_cache_enabled?
          fetch_fragment_cache(adapter_instance)
        else
          yield
        end
      end

      # 1. Create a CachedSerializer and NonCachedSerializer from the serializer class
      # 2. Serialize the above two with the given adapter
      # 3. Pass their serializations to the adapter +::fragment_cache+
      #
      # It will split the serializer into two, one that will be cached and one that will not
      #
      # Given a resource name
      # 1. Dynamically creates a CachedSerializer and NonCachedSerializer
      #   for a given class 'name'
      # 2. Call
      #       CachedSerializer.cache(serializer._cache_options)
      #       CachedSerializer.fragmented(serializer)
      #       NonCachedSerializer.cache(serializer._cache_options)
      # 3. Build a hash keyed to the +cached+ and +non_cached+ serializers
      # 4. Call +cached_attributes+ on the serializer class and the above hash
      # 5. Return the hash
      #
      # @example
      #   When +name+ is <tt>User::Admin</tt>
      #   creates the Serializer classes (if they don't exist).
      #     CachedUser_AdminSerializer
      #     NonCachedUser_AdminSerializer
      #
      # Given a hash of its cached and non-cached serializers
      # 1. Determine cached attributes from serializer class options
      # 2. Add cached attributes to cached Serializer
      # 3. Add non-cached attributes to non-cached Serializer
      def fetch_fragment_cache(adapter_instance)
        serializer_class_name = self.class.name.gsub('::'.freeze, '_'.freeze)
        self.class._cache_options ||= {}
        self.class._cache_options[:key] = self.class._cache_key if self.class._cache_key

        cached_serializer = _get_or_create_fragment_cached_serializer(serializer_class_name)
        cached_hash = ActiveModelSerializers::SerializableResource.new(
          object,
          serializer: cached_serializer,
          adapter: adapter_instance.class
        ).serializable_hash

        non_cached_serializer = _get_or_create_fragment_non_cached_serializer(serializer_class_name)
        non_cached_hash = ActiveModelSerializers::SerializableResource.new(
          object,
          serializer: non_cached_serializer,
          adapter: adapter_instance.class
        ).serializable_hash

        # Merge both results
        adapter_instance.fragment_cache(cached_hash, non_cached_hash)
      end

      def _get_or_create_fragment_cached_serializer(serializer_class_name)
        cached_serializer = _get_or_create_fragment_serializer "Cached#{serializer_class_name}"
        cached_serializer.cache(self.class._cache_options)
        cached_serializer.type(self.class._type)
        cached_serializer.fragmented(self)
        self.class.cached_attributes.each do |attribute|
          options = self.class._attributes_keys[attribute] || {}
          cached_serializer.attribute(attribute, options)
        end
        cached_serializer
      end

      def _get_or_create_fragment_non_cached_serializer(serializer_class_name)
        non_cached_serializer = _get_or_create_fragment_serializer "NonCached#{serializer_class_name}"
        non_cached_serializer.type(self.class._type)
        non_cached_serializer.fragmented(self)
        self.class.non_cached_attributes.each do |attribute|
          options = self.class._attributes_keys[attribute] || {}
          non_cached_serializer.attribute(attribute, options)
        end
        non_cached_serializer
      end

      def _get_or_create_fragment_serializer(name)
        return Object.const_get(name) if Object.const_defined?(name)
        Object.const_set(name, Class.new(ActiveModel::Serializer))
      end

      def cache_key(adapter_instance)
        return @cache_key if defined?(@cache_key)

        parts = []
        parts << object_cache_key
        parts << adapter_instance.cached_name
        parts << self.class._cache_digest unless self.class._skip_digest?
        @cache_key = parts.join('/')
      end

      # Use object's cache_key if available, else derive a key from the object
      # Pass the `key` option to the `cache` declaration or override this method to customize the cache key
      def object_cache_key
        if object.respond_to?(:cache_key)
          object.cache_key
        elsif (serializer_cache_key = (self.class._cache_key || self.class._cache_options[:key]))
          object_time_safe = object.updated_at
          object_time_safe = object_time_safe.strftime('%Y%m%d%H%M%S%9N') if object_time_safe.respond_to?(:strftime)
          "#{serializer_cache_key}/#{object.id}-#{object_time_safe}"
        else
          fail UndefinedCacheKey, "#{object.class} must define #cache_key, or the 'key:' option must be passed into '#{self.class}.cache'"
        end
      end
    end
  end
end
