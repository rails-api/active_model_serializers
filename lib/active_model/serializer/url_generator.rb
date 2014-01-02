module ActiveModel
  class Serializer
    class UrlGenerator
      attr_reader :url_options

      def initialize(url_options)
        @url_options = url_options
      end

    end
  end
end
