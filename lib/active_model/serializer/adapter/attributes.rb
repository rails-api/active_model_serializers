module ActiveModel
  class Serializer
    module Adapter
      class Attributes < Base
        def initialize(serializer, options = {})
          super
          @include_tree = IncludeTree.from_include_args(options[:include] || '*')
        end

        def serializable_hash(options = nil)
          options ||= {}
          if serializer.respond_to?(:each)
            result = serializer.map { |s| Attributes.new(s).serializable_hash(options) }
          else
            hash = {}

            core = cache_check(serializer) do
              serializer.attributes(options)
            end

            serializer.associations(@include_tree).each do |association|
              serializer = association.serializer
              association_options = association.options

              if serializer.respond_to?(:each)
                array_serializer = serializer
                hash[association.key] = array_serializer.map do |item|
                  cache_check(item) do
                    item.attributes(association_options)
                  end
                end
              else
                hash[association.key] =
                  if serializer && serializer.object
                    cache_check(serializer) do
                      serializer.attributes(options)
                    end
                  elsif association_options[:virtual_value]
                    association_options[:virtual_value]
                  end
              end
            end
            result = core.merge hash
          end
          result
        end

        def fragment_cache(cached_hash, non_cached_hash)
          Json::FragmentCache.new.fragment_cache(cached_hash, non_cached_hash)
        end

        private

        # no-op: Attributes adapter does not include meta data, because it does not support root.
        def include_meta(json)
          json
        end
      end
    end
  end
end
