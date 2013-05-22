module ActiveModel
  class Serializer
    module Caching
      def to_json(*args)
        if caching_enabled?
          key = expand_cache_key([self.class.to_s.underscore, cache_key, 'to-json'])
          cache.fetch key do
            super
          end
        else
          super
        end
      end

      def serialize(*args)
        if caching_enabled?
          key = expand_cache_key([self.class.to_s.underscore, cache_key, 'serialize'])
          cache.fetch key do
            serialize_object
          end
        else
          serialize_object
        end
      end

      private

      def caching_enabled?
        perform_caching && cache && respond_to?(:cache_key)
      end

      def expand_cache_key(*args)
        ActiveSupport::Cache.expand_cache_key(args)
      end
    end
  end
end
