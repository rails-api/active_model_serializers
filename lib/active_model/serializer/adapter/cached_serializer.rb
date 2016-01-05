module ActiveModel
  class Serializer
    module Adapter
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
          @klass._cache && !@klass._cache_only && !@klass._cache_except
        end

        def fragment_cached?
          @klass._cache_only && !@klass._cache_except || !@klass._cache_only && @klass._cache_except
        end

        def cache_key(adapter_instance)
          parts = []
          parts << object_cache_key
          parts << adapter_instance.name.underscore
          parts << @klass._cache_digest unless @klass._cache_options && @klass._cache_options[:skip_digest]
          parts.join('/')
        end

        def object_cache_key
          return @cached_serializer.object.cache_key if @cached_serializer.object.respond_to? :cache_key

          fail(UndefinedCacheKey, "#{@cached_serializer.object} must define #cache_key, or the cache_key option must be passed into cache on #{@cached_serializer}") if @klass._cache_key.blank?
          object_time_safe = @cached_serializer.object.updated_at
          object_time_safe = object_time_safe.strftime('%Y%m%d%H%M%S%9N') if object_time_safe.respond_to?(:strftime)
          "#{@klass._cache_key}/#{@cached_serializer.object.id}-#{object_time_safe}"
        end
      end
    end
  end
end
