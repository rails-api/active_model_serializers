module ActiveModel
  class Serializer
    module Configuration
      include ActiveSupport::Configurable
      extend ActiveSupport::Concern

      included do |base|
        base.config.array_serializer = ActiveModel::Serializer::ArraySerializer
        base.config.adapter = :flatten_json
        base.config.enabled_adapters_by_media_type = true
        base.config.custom_media_type_adapters = {}
      end
    end
  end
end
