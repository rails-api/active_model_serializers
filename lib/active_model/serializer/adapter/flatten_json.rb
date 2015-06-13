require 'active_model/serializer/adapter/json/fragment_cache'

module ActiveModel
  class Serializer
    class Adapter
      class FlattenJson < Json
        def serializable_hash(options = {})
          super
          @result
        end
      end

      def fragment_cache(cached_hash, non_cached_hash)
        Json::FragmentCache.new().fragment_cache(cached_hash, non_cached_hash)
      end
    end
  end
end
