module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        class PaginationLinks
          FIRST_PAGE = 1

          attr_reader :collection, :options

          def initialize(collection, options={})
            raise_unless_any_gem_installed
            @collection = collection
            @options = options
          end

          def page_links
            build_links
          end

          private

          def build_links
            pages_from.each_with_object({}) do |(key, value), hash|
              hash[key] = "#{url}?page=#{value}&per_page=#{collection.size}"
            end
          end

          def pages_from
            return {} if collection.total_pages == FIRST_PAGE

            {}.tap do |pages|
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
            raise "AMS relies on either Kaminari or WillPaginate." +
              "Please install either dependency by adding one of those to your Gemfile"
          end

          def url
            return default_url unless options && options[:links] && options[:links][:self]
            options[:links][:self]
          end

          def default_url
            options[:original_url]
          end
        end
      end
    end
  end
end
