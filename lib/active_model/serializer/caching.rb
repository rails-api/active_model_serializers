require "active_support/core_ext/module/attribute_accessors"

module ActiveModel
  class Serializer
    module Caching
      mattr_accessor :perform_caching
      mattr_accessor :cache_store

      def to_json(*args)
        if caching_enabled?
          key = expand_cache_key([self.class.to_s.underscore, cache_key, 'to-json'])
          cache_store.fetch key do
            super
          end
        else
          super
        end
      end

      def serialize(*args)
        if caching_enabled?
          key = expand_cache_key([self.class.to_s.underscore, cache_key, 'serialize'])
          cache_store.fetch key do
            serialize_object
          end
        else
          serialize_object
        end
      end

      private

      def caching_enabled?
        cache_configured? && cache_enabled && respond_to?(:cache_key)
      end

      def cache_configured?
        perform_caching && cache_store
      end

      def expand_cache_key(*args)
        ActiveSupport::Cache.expand_cache_key(args)
      end
    end
  end
end
