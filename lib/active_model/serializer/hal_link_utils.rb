module ActiveModel
  class Serializer
    module HalLinkUtils
      extend ActiveSupport::Concern

      included do
        class_attribute :_links
        self._links = {}
      end

      module ClassMethods #:nodoc:
        def link(rel, options={})
          self._links = _links.merge(rel => options)

          # protect inheritance chains and open classes
          # if a serializer inherits from another OR
          #  attributes are added later in a classes lifecycle
          # poison the cache
          define_method :_fast_links do
            raise NameError
          end
        end
      end

      # Returns a hash representation of the serializable
      # object links.
      def links
        _fast_links
      rescue NameError
        method = "def _fast_links\n"

        method << "  h = {}\n"

        _links.each do |rel, options|
          method << "  h[:\"#{rel}\"] = {\n"
          method << "    href: \"#{options[:href]}\",\n"
          method << "    templated: #{!!options[:templated]}\n" if options[:templated]
          method << "  }\n"
        end
        method << "  h\nend"

        self.class.class_eval method
        _fast_links
      end
    end
  end
end
