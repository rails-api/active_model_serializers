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
        config.key_transform = nil
        config.jsonapi_pagination_links_enabled = true
        config.jsonapi_resource_type = :plural
        config.jsonapi_namespace_separator = '-'.freeze
        config.jsonapi_version = '1.0'
        config.jsonapi_toplevel_meta = {}
        # Make JSON API top-level jsonapi member opt-in
        # ref: http://jsonapi.org/format/#document-top-level
        config.jsonapi_include_toplevel_object = false
        config.include_data_default = true

        # For configuring how serializers are found.
        # This should be an array of procs.
        #
        # The priority of the output is that the first item
        # in the evaluated result array will take precedence
        # over other possible serializer paths.
        #
        # i.e.: First match wins.
        #
        # @example output
        # => [
        #   "CustomNamespace::ResourceSerializer",
        #   "ParentSerializer::ResourceSerializer",
        #   "ResourceNamespace::ResourceSerializer" ,
        #   "ResourceSerializer"]
        #
        # If CustomNamespace::ResourceSerializer exists, it will be used
        # for serialization
        config.serializer_lookup_chain = ActiveModelSerializers::LookupChain::DEFAULT.dup

        config.schema_path = 'test/support/schemas'
      end
    end
  end
end
