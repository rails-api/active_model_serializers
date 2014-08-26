module ActiveModel
  class Serializer
    class Association
      class HasOne < Association
        def initialize(name, *args)
          super
          @root_key = @embedded_key.to_s.pluralize
          @key ||= "#{name}_id"
        end

        def serializer_class(object)
          serializer_from_options || serializer_from_object(object) || default_serializer
        end

        def build_serializer(object, options = {})
          options[:_wrap_in_array] = embed_in_root?
          super
        end
      end
    end
  end
end