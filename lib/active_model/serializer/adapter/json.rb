require 'active_model/serializer/adapter/json/fragment_cache'

module ActiveModel
  class Serializer
    class Adapter
      class Json < Adapter
        def serializable_hash(options = nil)
          options ||= {}
          if serializer.respond_to?(:each)
            @result = serialize_array_without_root(serializer, options)
          else
            @hash = {}

            @core = serialized_attributes_of(serializer, options)

            serializer.associations.each do |association|
              serializer = association.serializer
              opts = association.options

              if serializer.respond_to?(:each)
                @hash[association.key] = serialize_array(serializer, opts)
              else
                @hash[association.key] = serialized_or_virtual_of(serializer, opts)
              end
            end
            @result = @core.merge @hash
          end

          { root => @result }
        end

        def serialize_array_without_root(serializer, options)
          serializer.map { |s| FlattenJson.new(s).serializable_hash(options) }
        end

        # TODO: what is a virtual value?
        def serialized_or_virtual_of(serializer, options)
          if serializer && serializer.object
            serialized_attributes_of(serializer, options)
          elsif options[:virtual_value]
            options[:virtual_value]
          end
        end

        def serialized_attributes_of(item, options)
          cache_check(item) do
            item.attributes(options)
          end
        end

        def serialize_array(serializer, options)
          serializer.map do |item|
            serialized_attributes_of(item, options)
          end
        end

        def fragment_cache(cached_hash, non_cached_hash)
          Json::FragmentCache.new().fragment_cache(cached_hash, non_cached_hash)
        end

      end
    end
  end
end
