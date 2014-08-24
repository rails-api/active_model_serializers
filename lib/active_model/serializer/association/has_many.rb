module ActiveModel
  class Serializer
    class Association
      class HasMany < Association
        def initialize(name, *args)
          super
          @root_key = @embedded_key
          @key ||= "#{name.to_s.singularize}_ids"
        end

        def serializer_class(object)
          if use_array_serializer?
            ArraySerializer
          else
            serializer_from_options
          end
        end

        def options
          if use_array_serializer?
            { each_serializer: serializer_from_options }.merge! super
          else
            super
          end
        end

        private

        def use_array_serializer?
          !serializer_from_options ||
            serializer_from_options && !(serializer_from_options <= ArraySerializer)
        end
      end
    end
  end
end