module ActiveModelSerializers
  module Adapter
    class JsonApi
      class ResourceIdentifier
        def self.type_for(serializer, serializer_type = nil, transform_options = {})
          raw_type = serializer_type ? serializer_type : raw_type_from_serializer_object(serializer.object)
          JsonApi.send(:transform_key_casing!, raw_type, transform_options)
        end

        def self.for_type_with_id(type, id, options)
          return nil if id.blank?
          {
            id: id.to_s,
            type: type_for(:no_class_needed, type, options)
          }
        end

        def self.raw_type_from_serializer_object(object)
          class_name = object.class.name # should use model_name
          serializer_type = class_name.underscore
          singularize = ActiveModelSerializers.config.jsonapi_resource_type == :singular
          inflection = singularize ? :singularize : :pluralize
          serializer_type = ActiveSupport::Inflector.public_send(inflection, serializer_type)
          serializer_type
            .gsub!('/'.freeze, ActiveModelSerializers.config.jsonapi_namespace_separator)
          serializer_type
        end

        # {http://jsonapi.org/format/#document-resource-identifier-objects Resource Identifier Objects}
        def initialize(serializer, options)
          @id   = id_for(serializer)
          @type = type_for(serializer, options)
        end

        def as_json
          return nil if id.blank?
          { id: id, type: type }
        end

        protected

        attr_reader :id, :type

        private

        def type_for(serializer, transform_options)
          self.class.type_for(serializer, serializer._type, transform_options)
        end

        def id_for(serializer)
          serializer.read_attribute_for_serialization(:id).to_s
        end
      end
    end
  end
end
