module ActiveModelSerializers
  module Adapter
    class JsonApi
      class ResourceIdentifier
        def self.type_for(class_name, serializer_type = nil, transform_options = {})
          if serializer_type
            raw_type = serializer_type
          else
            inflection =
              if ActiveModelSerializers.config.jsonapi_resource_type == :singular
                :singularize
              else
                :pluralize
              end

            raw_type = class_name.underscore
            raw_type = ActiveSupport::Inflector.public_send(inflection, raw_type)
            raw_type
              .gsub!('/'.freeze, ActiveModelSerializers.config.jsonapi_namespace_separator)
            raw_type
          end
          JsonApi.send(:transform_key_casing!, raw_type, transform_options)
        end

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

        def type_for(serializer, transform_options)
          self.class.type_for(serializer.object.class.name, serializer._type, transform_options)
        end

        def id_for(serializer)
          serializer.read_attribute_for_serialization(:id).to_s
        end
      end
    end
  end
end
