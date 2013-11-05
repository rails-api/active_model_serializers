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
          if block_given?
            define_method("_generate_#{rel}_link") do
              yield self
            end
          end

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
          if respond_to?("_generate_#{rel}_link")
            method << "  h[:\"#{rel}\"] = _generate_#{rel}_link\n"
          else
            method << "  h[:\"#{rel}\"] = {\n"
            method << "    href: \"#{options[:href]}\",\n"
            method << "    templated: #{!!options[:templated]}\n" if options[:templated]
            method << "  }\n"
          end
        end
        method << "  h\nend"

        self.class.class_eval method
        _fast_links
      end
    end
  end
end
