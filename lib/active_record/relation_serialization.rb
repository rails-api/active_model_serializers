module ActiveRecord
  module RelationSerialization
    def serializer_class
      ActiveModelSerializers.config.collection_serializer
    end
  end
end
