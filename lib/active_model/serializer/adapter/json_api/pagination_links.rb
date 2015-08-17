module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        class PaginationLinks
          FIRST_PAGE = 1

          attr_reader :collection

          def initialize(collection)
            raise_unless_any_gem_installed
            @collection = collection
          end

          def serializable_hash(options = {})
            pages_from.each_with_object({}) do |(key, value), hash|
              query_parameters = options[:pagination].fetch(:query_parameters) { {} }
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

          def raise_unless_any_gem_installed
            return if defined?(WillPaginate) || defined?(Kaminari)
            raise <<-EOF
            AMS relies on either Kaminari or WillPaginate for pagination.
            Please install either dependency by adding one of those to your Gemfile.
            EOF
          end

          def url(options)
            self_link = options.fetch(:links) {{}}
            self_link.fetch(:self) {} ? options[:links][:self] : options[:pagination][:original_url]
          end
        end
      end
    end
  end
end
