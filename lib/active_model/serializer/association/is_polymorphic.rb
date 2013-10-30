module ActiveModel
  class Serializer
    class Association
      module IsPolymorphic
        def build_serializer(object)
          # serializer can be forced but it does not get memoized otherwise
          serializer = @serializer_class || Serializer.serializer_for(object) || DefaultSerializer
          serializer.new(object, @options)
        end

        protected

        def type_name(object)
          object.class.to_s.demodulize.underscore.to_sym
        end

        def serialize_single(object)
          type = type_name(object)
          result = super
          result ? { type: type, type => result } : nil
        end

        def serialize_id(elem)
          elem ? { id: super, type: type_name(elem) } : nil
        end
      end
    end
  end
end
