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

            @core = resource_object_for(serializer, options)

            add_resource_relationships(serializer)

            @result = @core.merge @hash
          end

          { root => @result }
        end

        def fragment_cache(cached_hash, non_cached_hash)
          Json::FragmentCache.new().fragment_cache(cached_hash, non_cached_hash)
        end

        private

        # iterate through the associations on the serializer,
        # adding them to @hash as needed (as singular or plural)
        def add_resource_relationships(serializer)
          serializer.associations.each do |association|
            serializer = association.serializer
            opts = association.options

            if serializer.respond_to?(:each)
              add_relationships(association.key, serializer, opts)
            else
              add_relationship(association.key, serializer, opts)
            end
          end

          @hash
        end

        # add a singular relationship
        def add_relationship(key, serializer, options)
          @hash[key] = serialized_or_virtual_of(serializer, options)
        end

        # add a many relationship
        def add_relationships(key, serializer, options)
          @hash[key] = serialize_array(serializer, options)
        end

        def serialize_array_without_root(serializer, options)
          serializer.map { |s| FlattenJson.new(s).serializable_hash(options) }
        end

        # a virtual value is something that doesn't need a serializer,
        # such as a ruby array, or any other raw value
        def serialized_or_virtual_of(serializer, options)
          if serializer && serializer.object
            resource_object_for(serializer, options)
          elsif options[:virtual_value]
            options[:virtual_value]
          end
        end

        def serialize_array(serializer, options)
          serializer.map do |item|
            resource_object_for(item, options)
          end
        end

        def resource_object_for(item, options)
          cache_check(item) do
            item.attributes(options)
          end
        end

      end
    end
  end
end
