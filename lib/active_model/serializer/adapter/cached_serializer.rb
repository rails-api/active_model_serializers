module ActiveModel
  class Serializer
    module Adapter
      class CachedSerializer
        def initialize(serializer)
          @cached_serializer = serializer
          @klass             = @cached_serializer.class
        end

        def cache_check(adapter_instance)
          if cached?
            @klass._cache.fetch(cache_key, @klass._cache_options) do
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

        def cache_key
          parts = []
          parts << object_cache_key
          parts << @klass._cache_digest unless @klass._cache_options && @klass._cache_options[:skip_digest]
          parts.join('/')
        end

        def object_cache_key
          object_time_safe = @cached_serializer.object.updated_at
          object_time_safe = object_time_safe.strftime('%Y%m%d%H%M%S%9N') if object_time_safe.respond_to?(:strftime)
          (@klass._cache_key) ? "#{@klass._cache_key}/#{@cached_serializer.object.id}-#{object_time_safe}" : @cached_serializer.object.cache_key
        end
      end
    end
  end
end
