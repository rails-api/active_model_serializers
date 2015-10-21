module ActiveModel
  class Serializer
    module Adapter
      class JsonApi < Base
        class PaginationLinks
          FIRST_PAGE = 1

          attr_reader :collection, :context

          def initialize(collection, context)
            @collection = collection
            @context = context
          end

          def serializable_hash(options = {})
            pages_from.each_with_object({}) do |(key, value), hash|
              params = query_parameters.merge(page: { number: value, size: collection.size }).to_query

              hash[key] = "#{url(options)}?#{params}"
            end
          end

          private

          def pages_from
            return {} if collection.total_pages == FIRST_PAGE

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
end
