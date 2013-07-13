module ActiveModel
  class Serializer
    module ArrayCaching
      def to_json(*args)
        if caching_enabled?
          keyed = keyed_hash('to-json')
          keys  = keyed.keys.map(&:dup)

          cached = cache.fetch_multi *keys do |key|
            keyed[key].to_json
          end

          "[#{cached.join(',')}]"
        else
          super
        end
      end

      def serialize(*args)
        if caching_enabled?
          keyed = keyed_hash('serialize')
          keys  = keyed.keys.map(&:dup)

          cache.fetch_multi *keys do |key|
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
    end
  end
end
