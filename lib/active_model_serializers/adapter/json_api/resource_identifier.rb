module ActiveModelSerializers
  module Adapter
    class JsonApi
      class ResourceIdentifier
        # {http://jsonapi.org/format/#document-resource-identifier-objects Resource Identifier Objects}
        def initialize(serializer, options)
          @id   = id_for(serializer)
          @type = type_for(serializer)
          @type = JsonApi.send(:transform_key_casing!, @type, options)
        end

        def as_json
          { id: id, type: type }
        end

        protected

        attr_reader :id, :type

        private

        def type_for(serializer)
          return serializer._type if serializer._type
          inflection =
            if ActiveModelSerializers.config.jsonapi_resource_type == :singular
              :singularize
            else
              :pluralize
            end
          raw_type = serializer.object.class.name
          raw_type = raw_type.underscore
          raw_type = ActiveSupport::Inflector.public_send(inflection, raw_type)
          raw_type
            .gsub!('/'.freeze, ActiveModelSerializers.config.jsonapi_namespace_separator)
          raw_type
        end

        def id_for(serializer)
          serializer.read_attribute_for_serialization(:id).to_s
        end
      end
    end
  end
end
