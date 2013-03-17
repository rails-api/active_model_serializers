module ActiveModel
  class Serializer
    class Responder < ::ActionController::Responder #:nodoc:

    protected
      def display(resource, given_options = {})
        if format != :json
          super
        else
          json = Serializer.build_json(controller, resource, options)

          if json
            render given_options.merge(options).merge(:json => json)
          else
            super
          end
        end
      end
    end
  end
end
