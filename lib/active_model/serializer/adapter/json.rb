require 'active_model/serializer/adapter/json/fragment_cache'

module ActiveModel
  class Serializer
    class Adapter
      class Json < Adapter
        def serializable_hash(options = nil)
          options ||= {}
          if serializer.respond_to?(:each)
            @result = serializer.map { |s| FlattenJson.new(s).serializable_hash(options) }
          else
            @hash = {}

            @core = cache_check(serializer) do
              serializer.attributes(options)
            end

            serializer.associations.each do |association|
              serializer = association.serializer
              opts = association.options

              if serializer.respond_to?(:each)
                array_serializer = serializer
                @hash[association.key] = array_serializer.map do |item|
                  cache_check(item) do
                    item.attributes(opts)
                  end
                end
              else
                @hash[association.key] =
                  if serializer && serializer.object
                    cache_check(serializer) do
                      serializer.attributes(options)
                    end
                  elsif opts[:virtual_value]
                    opts[:virtual_value]
                  end
              end
            end
            @result = @core.merge @hash
          end

          { root => @result }
        end

        def fragment_cache(cached_hash, non_cached_hash)
          Json::FragmentCache.new().fragment_cache(cached_hash, non_cached_hash)
        end
      end
    end
  end
end
