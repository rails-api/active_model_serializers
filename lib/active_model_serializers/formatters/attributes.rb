module ActiveModelSerializers
  module Formatters
    class Attributes
      attr_reader :jsonapi, :data, :included

      def initialize(jsonapi_hash)
        @jsonapi = jsonapi_hash
        @data = jsonapi_hash[:data]
        @included = jsonapi_hash[:included]
      end

      def render
        # TODO: relationships
        Array[*data].map { |datum| datum[:attributes] }
      end
    end
  end
end
