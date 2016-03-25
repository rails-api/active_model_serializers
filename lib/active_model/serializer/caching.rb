module ActiveModel
  class Serializer
    module Caching
      extend ActiveSupport::Concern

      included do
        with_options instance_writer: false, instance_reader: false do |serializer|
          serializer.class_attribute :_cache         # @api private : the cache store
          serializer.class_attribute :_fragmented    # @api private : @see ::fragmented
          serializer.class_attribute :_cache_key     # @api private : when present, is first item in cache_key
          serializer.class_attribute :_cache_only    # @api private : when fragment caching, whitelists cached_attributes. Cannot combine with except
          serializer.class_attribute :_cache_except  # @api private : when fragment caching, blacklists cached_attributes. Cannot combine with only
          serializer.class_attribute :_cache_options # @api private : used by CachedSerializer, passed to _cache.fetch
          #  _cache_options include:
          #    expires_in
          #    compress
          #    force
          #    race_condition_ttl
          #  Passed to ::_cache as
          #    serializer._cache.fetch(cache_key, @klass._cache_options)
          serializer.class_attribute :_cache_digest # @api private : Generated
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
          base._cache_digest = digest_caller_file(caller_line)
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
        # @params options [Hash] with valid keys:
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
      end
    end
  end
end
