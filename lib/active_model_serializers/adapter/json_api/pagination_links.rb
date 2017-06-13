module ActiveModelSerializers
  module Adapter
    class JsonApi < Base
      class PaginationLinks
        MissingSerializationContextError = Class.new(KeyError)

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
          {
            "self":  location_url,
            "first": first_page_url,
            "prev":  prev_page_url,
            "next":  next_page_url,
            "last":  last_page_url
          }
        end

        protected

        attr_reader :adapter_options

        private

        def location_url
          url_for_page(collection.current_page)
        end

        def first_page_url
          url_for_page(1)
        end

        def prev_page_url
          return nil if collection.first_page?
          url_for_page(collection.prev_page)
        end

        def next_page_url
          return nil if collection.last_page? || collection.out_of_range?
          url_for_page(collection.next_page)
        end

        def url_for_page(number)
          params = query_parameters.dup
          params[:page] = { page: per_page, number: number }
          context.url_for(action: :index, params: params)
        end

        def query_parameters
          @query_parameters ||= context.query_parameters
        end

        def per_page
          @per_page ||= collection.try(:per_page) || collection.try(:limit_value) || collection.size
        end
      end
    end
  end
end
