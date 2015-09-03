require 'active_model/serializer/adapter/fragment_cache'
module ActiveModel
  class Serializer
    class Adapter
      class Json < Adapter
        class FragmentCache

          def fragment_cache(cached_hash, non_cached_hash)
            core_cached = cached_hash.values.first
            core_non_cached = non_cached_hash.values.first

            if core_cached.is_a?(Hash) && core_non_cached.is_a?(Hash)
              core_non_cached.merge core_cached
            else
              non_cached_hash.merge cached_hash
            end
          end

        end
      end
    end
  end
end
