module ActiveModel
  class Serializer
    class UrlGenerator

      def initialize(current_url_options = {})
        @current_url_options = current_url_options
      end

      def url_options
        @url_options ||=
          Hash(CONFIG.default_url_options).merge(@current_url_options)
      end
    end
  end
end
