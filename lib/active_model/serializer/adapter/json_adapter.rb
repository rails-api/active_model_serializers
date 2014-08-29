module ActiveModel
  class Serializer
    class Adapter
      class JsonAdapter < Adapter
        def serializable_hash(options = {})
          serializer.attributes.each_with_object({}) do |(attr, value), h|
            h[attr] = value
          end
        end
      end
    end
  end
end
