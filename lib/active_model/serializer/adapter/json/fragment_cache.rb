module ActiveModel
  class Serializer
    class Adapter
      class Json < Adapter
        class FragmentCache

          def fragment_cache(cached_hash, non_cached_hash)
            non_cached_hash.merge cached_hash
          end

        end
      end
    end
  end
end