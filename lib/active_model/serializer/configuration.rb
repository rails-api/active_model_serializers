module ActiveModel
  class Serializer
    module Configuration
      include ActiveSupport::Configurable
      extend ActiveSupport::Concern

      included do |base|
        base.config.array_serializer = ActiveModel::Serializer::ArraySerializer
        base.config.adapter = :flatten_json
        base.config.jsonapi_resource_type = :plural
        base.config.jsonapi_toplevel_member = false
        base.config.jsonapi_version = '1.0'
      end
    end
  end
end
