module ActiveModel
  class Serializer
    module Adapter
      class Json
        class FragmentCache
          def fragment_cache(cached_hash, non_cached_hash)
            non_cached_hash.merge cached_hash
          end
        end
      end
    end
  end
end
