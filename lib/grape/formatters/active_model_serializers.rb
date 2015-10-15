# A Grape response formatter that can be used as 'formatter :json, Grape::Formatters::ActiveModelSerializers'
#
# Serializer options can be passed as a hash from your Grape endpoint using env[:active_model_serializer_options],
# or better yet user the render helper in Grape::Helpers::ActiveModelSerializers
module Grape
  module Formatters
    module ActiveModelSerializers
      def self.call(resource, env)
        serializer_options = {}
        serializer_options.merge!(env[:active_model_serializer_options]) if env[:active_model_serializer_options]
        ActiveModel::SerializableResource.new(resource, serializer_options).to_json
      end
    end
  end
end
