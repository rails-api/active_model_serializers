module ActiveModel
  class Serializer
    class Adapter
      class JsonApiAdapter < Adapter
        def serializable_hash(options = {})
          hash = serializer.attributes

          associations = serializer.associations(only: [:id]).each_with_object({}) do |(attr, value), h|
            h[attr] = case value
                       when ActiveModel::Serializer::ArraySerializer
                         value.attributes(options).map do |item|
                           item.id
                         end.to_a
                       when ActiveModel::Serializer
                         # process belongs_to association
                       else
                         # what?
                       end
          end
          hash.merge(associations)
        end
      end
    end
  end
end
