module ActiveModelSerializers
  module Adapter
    class JsonApi < Base
      class PaginationLinks
        MissingSerializationContextError = Class.new(KeyError)
        FIRST_PAGE = 1

        attr_reader :collection, :context

        def initialize(collection, adapter_options)
          @collection = collection
          @adapter_options = adapter_options
          @context = adapter_options.fetch(:serialization_context) do
            fail MissingSerializationContextError, <<-EOF.freeze
 JsonApi::PaginationLinks requires a ActiveModelSerializers::SerializationContext.
 Please pass a ':serialization_context' option or
 override CollectionSerializer#paginated? to return 'false'.
             EOF
          end
        end

        def as_json
          per_page = collection.try(:per_page) || collection.try(:limit_value) || collection.size
          pages_from.each_with_object({}) do |(key, value), hash|
            params = query_parameters.merge(page: { number: value, size: per_page }).to_query

            hash[key] = "#{url(adapter_options)}?#{params}"
          end
        end

        protected

        attr_reader :adapter_options

        private

        def pages_from
          return {} if collection.total_pages <= FIRST_PAGE

          {}.tap do |pages|
            pages[:self] = collection.current_page

            unless collection.current_page == FIRST_PAGE
              pages[:first] = FIRST_PAGE
              pages[:prev]  = collection.current_page - FIRST_PAGE
            end

            unless collection.current_page == collection.total_pages
              pages[:next] = collection.current_page + FIRST_PAGE
              pages[:last] = collection.total_pages
            end
          end
        end

        def url(options)
          @url ||= options.fetch(:links, {}).fetch(:self, nil) || request_url
        end

        def request_url
          @request_url ||= context.request_url
        end

        def query_parameters
          @query_parameters ||= context.query_parameters
        end
      end
    end
  end
end
