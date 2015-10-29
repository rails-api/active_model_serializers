module ActionController
  module Serialization
    class Context
      attr_reader :request_url, :query_parameters, :url_helpers

      def initialize(request)
        @request_url = request.original_url[/\A[^?]+/]
        @query_parameters = request.query_parameters
        @url_helpers = ActiveModelSerializers.url_helpers
      end
    end
  end
end
