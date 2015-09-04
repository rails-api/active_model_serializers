class ActiveModel::Serializer::Adapter::Json < ActiveModel::Serializer::Adapter
        extend ActiveSupport::Autoload
        autoload :FragmentCache

        def serializable_hash(options = nil)
          options ||= {}
          { root => FlattenJson.new(serializer).serializable_hash(options) }
        end

        private

        def fragment_cache(cached_hash, non_cached_hash)
          ActiveModel::Serializer::Adapter::Json::FragmentCache.new.fragment_cache(cached_hash, non_cached_hash)
        end
end
