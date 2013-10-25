module ActiveModel
  class Serializer
    class Association
      class HasManyPolymorphic < HasMany
        def build_serializer(object)
          serializer = @serializer_class || Serializer.serializer_for(object) || DefaultSerializer
          serializer.new(object, @options)
        end

        def type_name(object)
          object.class.to_s.demodulize.underscore.to_sym
        end

        def serialize(objects)
          objects.map do |object|
            object ? serialize_single(object).merge!(type: type_name(object)) : nil
          end
        end

        protected

        def serialize_id(elem)
          elem ? { id: super, type: type_name(elem) } : nil
        end
      end
    end
  end
end