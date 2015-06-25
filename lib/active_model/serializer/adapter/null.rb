module ActiveModel
  class Serializer
    class Adapter
      class Null < Adapter
        def serializable_hash(options = nil)
          {}
        end
      end
    end
  end
end
