module ActiveModelSerializers
  class SerializationContext
    attr_reader :request_url, :query_parameters, :controller_namespace, :parent_serializer_namespace

    def initialize(options = {})
      self.controller = options[:controller] if options.key?(:controller)
      self.parent_serializer = options[:parent_serializer] if options.key?(:parent_serializer)
    end

    def controller=(controller)
      @request_url = controller.request.original_url[/\A[^?]+/]
      @query_parameters = controller.request.query_parameters
      @controller_namespace = controller.class.to_s.deconstantize
    end

    def parent_serializer=(parent_serializer)
      @parent_serializer_namespace = parent_serializer.class.to_s.deconstantize
    end
  end
end
