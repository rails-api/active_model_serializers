module ActiveModelSerializers
  class SerializationContext
    attr_reader :request_url, :query_parameters, :controller_namespace

    def initialize(options = {})
      if (controller = options[:controller])
        @request_url = controller.request.original_url[/\A[^?]+/]
        @query_parameters = controller.request.query_parameters
        @controller_namespace = controller.class.to_s.deconstantize
      end
      if (parent_serializer = options[:parent_serializer])
        @parent_serializer_namespace = parent_serializer.class.to_s.deconstantize
      end
    end
  end
end
