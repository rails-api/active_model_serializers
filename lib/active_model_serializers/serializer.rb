module ActiveModelSerializers
  class Serializer < JSONAPI::Serializable::Resource
    class << self
      def render(object, options = {})
        result = _success_renderer.render(object, options)

        return _attributes_for(result) if _adapter == :attributes
        return _json_for(result) if _adapter == :json

        result
      end

      # @api private
      def _attributes_for(jsonapi)
        Formatters::Attributes.new(jsonapi).render
      end

      # @api private
      def _json_for(jsonapi)
        Formatters::Json.new(jsonapi).render
      end

      # @api private
      def _adapter
        ActiveModelSerializers.adapter
      end

      # @api private
      def _success_renderer
        @_success_renderer ||= JSONAPI::Serializable::SuccessRenderer.new
      end

      # @api private
      def _error_renderer
        @_error_renderer ||= JSONAPI::Serializable::ErrorRenderer.new
      end
    end
  end
end
