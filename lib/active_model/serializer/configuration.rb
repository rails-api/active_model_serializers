module ActiveModel
  class Serializer
    module Configuration
      include ActiveSupport::Configurable
      extend ActiveSupport::Concern

      included do |base|
        base.config.array_serializer = ActiveModel::Serializer::ArraySerializer
        base.config.adapter = :flatten_json
        base.config.jsonapi_resource_type = :plural
        base.config.jsonapi_type_formatter = -> (type) { type.pluralize }
      end
    end
  end
end
