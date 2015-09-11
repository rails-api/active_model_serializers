class ActiveModel::Serializer::Adapter::Json::FragmentCache
          def fragment_cache(cached_hash, non_cached_hash)
            non_cached_hash.merge cached_hash
          end
end
