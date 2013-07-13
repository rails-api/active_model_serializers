module ActiveModel
  class Serializer
    module Caching
      def to_json(*args)
        if caching_enabled?
          cache.fetch expanded_cache_key('to-json') do
            super
          end
        else
          super
        end
      end

      def serialize(*args)
        if caching_enabled?
          cache.fetch expanded_cache_key('serialize') do
            serialize_object
          end
        else
          serialize_object
        end
      end

      def expanded_cache_key(suffix)
        expand_cache_key([self.class.to_s.underscore, cache_key, suffix])
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
