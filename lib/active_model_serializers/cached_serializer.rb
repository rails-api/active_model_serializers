module ActiveModelSerializers
  class CachedSerializer
    UndefinedCacheKey = Class.new(StandardError)

    def initialize(serializer)
      @cached_serializer = serializer
      return unless cached? && !@cached_serializer.object.respond_to?(:cache_key) && @klass._cache_key.blank?
      fail(UndefinedCacheKey, "#{@cached_serializer.object} must define #cache_key, or the cache_key option must be passed into cache on #{@cached_serializer}")
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
      parts << @cached_serializer.cache_key
      parts << adapter_instance.name.underscore
      parts << @klass._cache_digest unless @klass._skip_digest?
      @cache_key = parts.join('/')
    end

    # find all cache_key for the collection_serializer
    # @param collection_serializer
    # @param include_tree
    # @return [Array] all cache_key of collection_serializer
    def self.object_cache_keys(serializers, include_tree)
      cache_keys = []

      serializers.each do |serializer|
        cache_keys << object_cache_key(serializer)

        serializer.associations(include_tree).each do |association|
          if association.serializer.respond_to?(:each)
            association.serializer.each do |sub_serializer|
              cache_keys << object_cache_key(sub_serializer)
            end
          else
            cache_keys << object_cache_key(association.serializer)
          end
        end
      end

      cache_keys.compact.uniq
    end

    # @return [String, nil] the cache_key of the serializer or nil
    def self.object_cache_key(serializer)
      return unless serializer.present? && serializer.object.present?

      cached_serializer = new(serializer)
      cached_serializer.cached? ? cached_serializer.cache_key : nil
    end
  end
end
