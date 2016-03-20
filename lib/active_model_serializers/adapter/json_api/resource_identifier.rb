module ActiveModelSerializers
  module Adapter
    class JsonApi
      class ResourceIdentifier
        # {http://jsonapi.org/format/#document-resource-identifier-objects Resource Identifier Objects}
        def initialize(serializer, options)
          @id   = id_for(serializer)
          @type = type_for(serializer, options)
        end

        def as_json
          { id: id, type: type }
        end

        protected

        attr_reader :id, :type

        private

        def type_for(serializer, options = {})
          return apply_key_transform(serializer._type, options) if serializer._type
          type = serializer.object.class.to_s.split('::')
          type = apply_key_transform(type, options)
          type = type.join ActiveModelSerializers.config.jsonapi_namespace_separator
          if ActiveModelSerializers.config.jsonapi_resource_type == :plural
            type = type.pluralize
          end

          type
        end

        def id_for(serializer)
          serializer.read_attribute_for_serialization(:id).to_s
        end

        def apply_key_transform(type, options)
          return type.map{ |t| apply_key_transform(t, options) } if type.is_a?(Array)
          # type = JsonApi.send(:transform_key_casing!, type, options)
          KeyTransform.transform(type, ActiveModelSerializers.config.jsonapi_type_transform)
        end
      end
    end
  end
end
