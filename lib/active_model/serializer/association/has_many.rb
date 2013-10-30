module ActiveModel
  class Serializer
    class Association
      class HasMany < Association
        def initialize(*args)
          super
          @key ||= "#{name.singularize}_ids"
        end

        def serialize(objects)
          if serializer_class && serializer_class <= ArraySerializer
            build_serializer(objects).serializable_object
          else
            objects.map { |object| serialize_single(object) }
          end
        end

        def serialize_ids(objects)
          objects.map { |object| serialize_id(object) }
        end
      end
    end
  end
end