module ActiveModel
  class Serializer
    module ArrayCaching
      def to_json(*args)
        if caching_enabled?
          keyed = object.inject({}) do |hash, obj|
            hash[obj.cache_key] = obj
            hash
          end

          cached = cache.fetch_multi keyed.keys do |key|
            keyed[key].to_json
          end

          values_to_json(cached)
        else
          super
        end
      end

      def serialize(*args)
        if caching_enabled?
          serialize_object
        else
          serialize_object
        end
      end

      private

      def caching_enabled?
        perform_caching && cache
      end

      def values_to_json(values)
        "[#{values.join(',')}]"
      end
    end
  end
end
