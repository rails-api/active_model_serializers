module ActiveModel
  class Serializer
    class Adapter
      class NullAdapter < Adapter
        def serializable_hash(options = {})
          {}
        end
      end
    end
  end
end
