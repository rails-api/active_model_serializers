module ActiveModel
  class Serializer
    module ArrayCaching
      def to_json(*args)
        if caching_enabled?
          keyed = keyed_hash('to-json')

          cached = cache.fetch_multi *keyed.keys do |key|
            keyed[key].to_json
          end

          values_to_json(cached)
        else
          super
        end
      end

      def serialize(*args)
        if caching_enabled?
          keyed = keyed_hash('serialize')

          cache.fetch_multi keyed.keys do |key|
            keyed[key].serialize
          end
        else
          serialize_object
        end
      end

      private

      def caching_enabled?
        perform_caching && cache
      end

      def keyed_hash(suffix)
        serializable_array.inject({}) do |hash, obj|
          hash[obj.expanded_cache_key(suffix)] = obj
          obj.perform_caching = false
          hash
        end
      end

      def values_to_json(values)
        "[#{values.join(',')}]"
      end
    end
  end
end
