module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        ResourceIdentifier = Struct.new(:id, :type) do
          def self.type_for(serializer)
            return serializer._type if serializer._type
            if ActiveModel::Serializer.config.jsonapi_resource_type == :singular
              serializer.object.class.model_name.singular
            else
              serializer.object.class.model_name.plural
            end
          end

          def self.id_for(serializer)
            if serializer.respond_to?(:id)
              serializer.id
            else
              serializer.object.id
            end
          end

          def self.from_serializer(serializer)
            new(id_for(serializer), type_for(serializer))
          end

          def to_h
            { id: id.to_s, type: type }
          end
        end
      end
    end
  end
end
