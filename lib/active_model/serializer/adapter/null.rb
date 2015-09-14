class ActiveModel::Serializer::Adapter::Null < ActiveModel::Serializer::Adapter
        def serializable_hash(_options = nil)
          {}
        end
end
