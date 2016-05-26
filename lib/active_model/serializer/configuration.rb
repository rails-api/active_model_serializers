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
        config.serializer_lookup_enabled = true

        def config.array_serializer=(collection_serializer)
          self.collection_serializer = collection_serializer
        end

        def config.array_serializer
          collection_serializer
        end

        config.default_includes = '*'
        config.adapter = :attributes
        config.jsonapi_resource_type = :plural
        config.jsonapi_version = '1.0'
        config.jsonapi_toplevel_meta = {}
        # Make JSON API top-level jsonapi member opt-in
        # ref: http://jsonapi.org/format/#document-top-level
        config.jsonapi_include_toplevel_object = false
        config.key_transform = nil

        config.schema_path = 'test/support/schemas'
      end
    end
  end
end
