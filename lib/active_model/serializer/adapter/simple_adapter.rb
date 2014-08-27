module ActiveModel
  class Serializer
    class Adapter
      class SimpleAdapter < Adapter
        def serializable_hash(options = {})
          serializer.attributes.each_with_object({}) do |(attr, value), h|
            h[attr] = value
          end
        end

        def to_json(options={})
          serializable_hash(options).to_json
        end
      end
    end
  end
end
