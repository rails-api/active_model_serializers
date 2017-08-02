module ActiveModelSerializers
  module Formatters
    class Json
      attr_reader :jsonapi, :data, :included

      def initialize(jsonapi_hash)
        @jsonapi = jsonapi_hash
        @data = jsonapi_hash[:data]
        @included = jsonapi_hash[:included]
      end

      def render
        # TODO: relationships
        { key => datas.map { |datum| datum[:attributes] } }
      end

      private

      def datas
        @datas ||= Array[*data]
      end

      def key
        @key ||= datas.first[:type]
      end
    end
  end
end
