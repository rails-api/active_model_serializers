module ActiveModel
  class Serializer
    class Pagination
      attr_reader :collection

      def initialize(collection)
        @collection = collection
      end

      def page_links
        send(default_adapter)
      end

      private

      def kaminari
        build_links collection.size
      end

      def will_paginate
        setup_will_paginate
        build_links collection.per_page
      end

      def build_links(per_page)
        pages_from.each_with_object({}) do |(key, value), hash|
          hash[key] = "?page=#{value}&per_page=#{per_page}"
        end
      end

      def pages_from
        return {} if collection.total_pages == 1

        {}.tap do |pages|
          unless collection.first_page?
            pages[:first] = 1
            pages[:prev]  = collection.current_page - 1
          end

          unless collection.last_page?
            pages[:next] = collection.current_page + 1
            pages[:last] = collection.total_pages
          end
        end
      end

      def default_adapter
        return :kaminari if defined?(Kaminari)
        return :will_paginate if defined?(WillPaginate::CollectionMethods)
        raise "AMS relies on either Kaminari or WillPaginate." +
          "Please install either dependency by adding one of those to your Gemfile"
      end

      def setup_will_paginate
        WillPaginate::CollectionMethods.module_eval do
          def first_page?() !previous_page end
          def last_page?() !next_page end
        end
      end
    end
  end
end
