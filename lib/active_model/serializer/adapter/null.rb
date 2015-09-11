class ActiveModel::Serializer::Adapter::Null < ActiveModel::Serializer::Adapter
        def serializable_hash(options = nil)
          {}
        end
end
