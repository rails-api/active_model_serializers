module ActiveModel
  class Serializer
    class Association
      class HasOne < Association
        def initialize(name, *args)
          super
          @root_key = @embedded_key.to_s.pluralize
          @key ||= case CONFIG.default_key_type
            when :name then name.to_s.singularize
            else "#{name}_id"
          end
        end

        def serializer_class(object, options = {})
          (serializer_from_options unless object.nil?) || serializer_from_object(object, options) || default_serializer
        end

        def build_serializer(object, options = {})
          options[:_wrap_in_array] = embed_in_root?
          super
        end
      end
    end
  end
end