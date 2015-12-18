module ActiveModel
  class Serializer
    module Configuration
      include ActiveSupport::Configurable
      extend ActiveSupport::Concern

      # Configuration options may also be set in
      # Serializers and Adapters
      included do |base|
        config = base.config
        config.collection_serializer = ActiveModel::Serializer::CollectionSerializer

        def config.array_serializer=(collection_serializer)
          self.collection_serializer = collection_serializer
        end

        def config.array_serializer
          collection_serializer
        end

        config.adapter = :attributes
        config.jsonapi_resource_type = :plural
        config.automatic_lookup = true
      end
    end
  end
end
