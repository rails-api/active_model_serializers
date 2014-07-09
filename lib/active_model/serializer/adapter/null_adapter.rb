module ActiveModel
  class Serializer
    class Adapter
      class NullAdapter
        def initialize(serializer)
          @serializer = serializer
        end

        def to_json
          @serializer.attributes.each_with_object({}) do |(attr, value), h|
            h[attr] = value
          end.to_json
        end
      end
    end
  end
end
