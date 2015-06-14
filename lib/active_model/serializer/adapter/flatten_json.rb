module ActiveModel
  class Serializer
    class Adapter
      class FlattenJson < Json
        def serializable_hash(options = {})
          super
          @result
        end
      end
    end
  end
end
