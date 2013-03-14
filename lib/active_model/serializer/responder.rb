module ActiveModel
  class Serializer
    class Responder < ::ActionController::Responder #:nodoc:
      attr_reader :serializer

    protected
      def display(resource, given_options = {})
        if format != :json
          super
        else
          default_options = controller.send(:default_serializer_options)
          options = self.options.reverse_merge(default_options || {})

          serializer = options[:serializer] ||
            (resource.respond_to?(:active_model_serializer) &&
             resource.active_model_serializer)

          if resource.respond_to?(:to_ary)
            unless serializer <= ActiveModel::ArraySerializer
              raise ArgumentError.new("#{serializer.name} is not an ArraySerializer. " +
                 "You may want to use the :each_serializer option instead.")
            end

            if options[:root] != false && serializer.root != false
              # default root element for arrays is serializer's root or the controller name
              # the serializer for an Array is ActiveModel::ArraySerializer
              options[:root] ||= serializer.root || controller.send(:controller_name)
            end
          end

          if serializer
            serialization_scope = controller.send(:serialization_scope)
            options[:scope] = serialization_scope unless options.has_key?(:scope)
            options[:url_options] = controller.send(:url_options)
            render(given_options.merge(:json => serializer.new(resource, options)))
          else
            super
          end
        end
      end
    end
  end
end