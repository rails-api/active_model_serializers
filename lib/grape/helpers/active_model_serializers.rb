# Helpers can be included in your Grape endpoint as: helpers Grape::Helpers::ActiveModelSerializers

require 'active_model_serializers/serialization_context'

module Grape
  module Helpers
    module ActiveModelSerializers
      # A convenience method for passing ActiveModelSerializers serializer options
      #
      # Example: To include relationships in the response: render(post, include: ['comments'])
      #
      # Example: To include pagination meta data: render(posts, meta: { page: posts.page, total_pages: posts.total_pages })
      def render(resource, active_model_serializer_options = {})
        active_model_serializer_options.fetch(:serialization_context) do
          active_model_serializer_options[:serialization_context] = ::ActiveModelSerializers::SerializationContext.new(
            original_url: request.url[/\A[^?]+/],
            query_parameters: request.params
          )
        end
        env[:active_model_serializer_options] = active_model_serializer_options
        resource
      end
    end
  end
end
