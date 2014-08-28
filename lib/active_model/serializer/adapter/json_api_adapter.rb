module ActiveModel
  class Serializer
    class Adapter
      class JsonApiAdapter < Adapter
        def serializable_hash(options = {})
          hash = serializer.attributes.each_with_object({}) do |(attr, value), h|
            h[attr] = value
          end

          serializer.associations(only: [:id]).each_with_object({}) do |(attr, value), h|
            case value
            when ActiveModel::Serializer::ArraySerializer
              # process has_many association
            when ActiveModel::Serializer
              # process belongs_to association
            else
              # what?
            end
          end
        end
      end
    end
  end
end
