module ActiveModelSerializers
  module Adapter
    class Json < Base
      extend ActiveSupport::Autoload
      autoload :FragmentCache

      def serializable_hash(options = nil)
        options ||= {}
        { root => Attributes.new(serializer, instance_options).serializable_hash(options) }
      end

      private

      def fragment_cache(cached_hash, non_cached_hash)
        ActiveModelSerializers::Adapter::Json::FragmentCache.new.fragment_cache(cached_hash, non_cached_hash)
      end
    end
  end
end
