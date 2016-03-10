module ActiveModelSerializers
  class SerializationContext
    class << self
      attr_writer :url_helpers, :default_url_options
    end

    attr_reader :request_url, :query_parameters, :key_transform

    def initialize(request, options = {})
      @request_url = request.original_url[/\A[^?]+/]
      @query_parameters = request.query_parameters
      @url_helpers = options.delete(:url_helpers) || self.class.url_helpers
      @default_url_options = options.delete(:default_url_options) || self.class.default_url_options
      @key_transform = options.delete(:key_transform)
    end

    def self.url_helpers
      @url_helpers ||= Module.new
    end

    def self.default_url_options
      @default_url_options ||= {}
    end
  end
end
