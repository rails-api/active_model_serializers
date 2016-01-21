module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class ResourceIdentifier
          def initialize(serializer)
            @id = id_for(serializer)
            @type = type_for(serializer)
          end

          def as_json
            { id: @id.to_s, type: @type }
          end

          protected

          attr_reader :object, :scope

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
            if serializer.respond_to?(:id)
              serializer.id
            else
              serializer.object.id
            end
          end
        end
      end
    end
  end
end
