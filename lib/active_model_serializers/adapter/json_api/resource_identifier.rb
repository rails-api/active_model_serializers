module ActiveModelSerializers
  module Adapter
    class JsonApi
      class ResourceIdentifier
        def initialize(serializer)
          @id   = id_for(serializer)
          @type = type_for(serializer)
        end

        def as_json
          { id: id, type: type }
        end

        protected

        attr_reader :id, :type

        private

        def type_for(serializer)
          return serializer._type if serializer._type
          if ActiveModelSerializers.config.jsonapi_resource_type == :singular
            serializer.object.class.model_name.singular
          else
            serializer.object.class.model_name.plural
          end
        end

        def id_for(serializer)
          serializer.read_attribute_for_serialization(:id).to_s
        end
      end
    end
  end
end
