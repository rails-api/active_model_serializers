module ActiveModel
  class Serializer
    module Links
      extend ActiveSupport::Concern

      included do
        with_options instance_writer: false, instance_reader: true do |serializer|
          serializer.class_attribute :_links # @api private
          self._links ||= {}
        end

        extend ActiveSupport::Autoload
      end

      module ClassMethods
        def inherited(base)
          super
          base._links = _links.dup
        end

        # Define a link on a serializer.
        # @example
        #   link(:self) { resource_url(object) }
        # @example
        #   link(:self) { "http://example.com/resource/#{object.id}" }
        # @example
        #   link :resource, "http://example.com/resource"
        #
        def link(name, value = nil, &block)
          _links[name] = block || value
        end
      end
    end
  end
end
