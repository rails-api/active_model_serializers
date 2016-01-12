module ActiveModel
  class Serializer
    module Adapter
      class CachedSerializer
        UndefinedCacheKey = Class.new(StandardError)

        def initialize(serializer)
          @cached_serializer = serializer
          @klass             = @cached_serializer.class
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
          @klass._cache && !@klass._cache_only && !@klass._cache_except
        end

        def fragment_cached?
          @klass._cache_only && !@klass._cache_except || !@klass._cache_only && @klass._cache_except
        end

        def cache_key(adapter_instance)
          parts = []
          parts << @cached_serializer.cache_key
          parts << adapter_instance.name.underscore
          parts << @klass._cache_digest unless @klass._skip_digest?
          parts.join('/')
        end
      end
    end
  end
end
