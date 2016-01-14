module ActiveModelSerializers
  class SerializationContext
    attr_reader :request_url, :query_parameters, :controller_namespace

    def initialize(controller)
      @request_url = controller.request.original_url[/\A[^?]+/]
      @query_parameters = controller.request.query_parameters
      @controller_namespace = controller.class.to_s.deconstantize
    end
  end
end
