module ActiveModel
  class Serializer
    module Configuration
      include ActiveSupport::Configurable
      extend ActiveSupport::Concern

      included do |base|
        base.config.array_serializer = ActiveModel::Serializer::ArraySerializer
        base.config.adapter = :flatten_json
      end
    end
  end
end
