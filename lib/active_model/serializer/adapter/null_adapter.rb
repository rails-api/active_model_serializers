module ActiveModel
  class Serializer
    class Adapter
      class NullAdapter < Adapter
        def serializable_hash(options = {})
          {}
        end

        def to_json(options = {})
          serializable_hash.to_json
        end
      end
    end
  end
end
