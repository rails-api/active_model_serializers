module ActiveModelSerializers
  class CachedSerializer
    UndefinedCacheKey = Class.new(StandardError)

    def initialize(serializer)
      @cached_serializer = serializer
      @klass             = @cached_serializer.class
    end

    def cache_check(adapter_instance)
      if cached?
        @klass._cache.fetch(cache_key(adapter_instance), @klass._cache_options) do
          yield
        end
      elsif fragment_cached?
        FragmentCache.new(adapter_instance, @cached_serializer, adapter_instance.instance_options).fetch
      else
        yield
      end
    end

    def cached?
      @klass.cache_enabled?
    end

    def fragment_cached?
      @klass.fragment_cache_enabled?
    end

    def cache_key(adapter_instance)
      return @cache_key if defined?(@cache_key)

      parts = []
      parts << object_cache_key
      parts << adapter_instance.cached_name
      parts << @klass._cache_digest unless @klass._skip_digest?
      @cache_key = parts.join('/')
    end

    # Use object's cache_key if available, else derive a key from the object
    # Pass the `key` option to the `cache` declaration or override this method to customize the cache key
    def object_cache_key
      if @cached_serializer.object.respond_to?(:cache_key)
        @cached_serializer.object.cache_key
      elsif (cache_key = (@klass._cache_key || @klass._cache_options[:key]))
        object_time_safe = @cached_serializer.object.updated_at
        object_time_safe = object_time_safe.strftime('%Y%m%d%H%M%S%9N') if object_time_safe.respond_to?(:strftime)
        "#{cache_key}/#{@cached_serializer.object.id}-#{object_time_safe}"
      else
        fail UndefinedCacheKey, "#{@cached_serializer.object.class} must define #cache_key, or the 'key:' option must be passed into '#{@klass}.cache'"
      end
    end

    # find all cache_key for the collection_serializer
    # @param collection_serializer
    # @param include_tree
    # @return [Array] all cache_key of collection_serializer
    def self.object_cache_keys(serializers, adapter_instance, include_tree)
      cache_keys = []

      serializers.each do |serializer|
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
    def self.object_cache_key(serializer, adapter_instance)
      return unless serializer.present? && serializer.object.present?

      cached_serializer = new(serializer)
      cached_serializer.cached? ? cached_serializer.cache_key(adapter_instance) : nil
    end
  end
end
