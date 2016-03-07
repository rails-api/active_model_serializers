module ActiveModelSerializers
  class SerializationContext
    attr_reader :request_url, :query_parameters, :controller_namespace

    def initialize(options = {})
      self.controller = options[:controller] if options.key?(:controller)
    end

    def controller=(controller)
      @request_url = controller.request.original_url[/\A[^?]+/]
      @query_parameters = controller.request.query_parameters
      @controller_namespace = controller.class.to_s.deconstantize
    end
  end
end
