module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        class FragmentCache

          def fragment_cache(root, cached_hash, non_cached_hash)
            hash              = {}
            core_cached       = cached_hash.first
            core_non_cached   = non_cached_hash.first
            no_root_cache     = cached_hash.delete_if {|key, value| key == core_cached[0] }
            no_root_non_cache = non_cached_hash.delete_if {|key, value| key == core_non_cached[0] }
            cached_resource   = (core_cached[1]) ? core_cached[1].merge(core_non_cached[1]) : core_non_cached[1]
            hash = (root) ? { root => cached_resource } : cached_resource
            hash.merge no_root_non_cache.merge no_root_cache
          end

        end
      end
    end
  end
end