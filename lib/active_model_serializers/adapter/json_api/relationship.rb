module ActiveModelSerializers
  module Adapter
    class JsonApi
      class Relationship
        # {http://jsonapi.org/format/#document-resource-object-related-resource-links Document Resource Object Related Resource Links}
        # {http://jsonapi.org/format/#document-links Document Links}
        # {http://jsonapi.org/format/#document-resource-object-linkage Document Resource Relationship Linkage}
        # {http://jsonapi.org/format/#document-meta Document Meta}
        def initialize(parent_serializer, serializable_resource_options, association)
          @parent_serializer = parent_serializer
          @association = association
          @serializable_resource_options = serializable_resource_options
        end

        def as_json
          hash = {}

          if association.options[:include_data]
            hash[:data] = data_for(association)
          end

          links = links_for(association)
          hash[:links] = links if links.any?

          meta = meta_for(association)
          hash[:meta] = meta if meta
          hash[:meta] = {} if hash.empty?

          hash
        end

        protected

        attr_reader :parent_serializer, :serializable_resource_options, :association

        private

        def data_for(association)
          serializer = association.serializer
          if serializer.respond_to?(:each)
            serializer.map { |s| ResourceIdentifier.new(s, serializable_resource_options).as_json }
          elsif (virtual_value = association.options[:virtual_value])
            virtual_value
          elsif serializer && serializer.object
            ResourceIdentifier.new(serializer, serializable_resource_options).as_json
          end
        end

        def links_for(association)
          association.links.each_with_object({}) do |(key, value), hash|
            result = Link.new(parent_serializer, value).as_json
            hash[key] = result if result
          end
        end

        def meta_for(association)
          meta = association.meta
          meta.respond_to?(:call) ? parent_serializer.instance_eval(&meta) : meta
        end
      end
    end
  end
end
