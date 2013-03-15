require 'active_support/inflector'

module ActiveModel
  class Serializer
    module CamelizeKeys #:nodoc:

      def self.included(base)
        class << base
          def attribute(attr, options = {})
            unless attr.is_a?(Hash)
              unless options[:key]
                attr = { attr => attr.to_s.camelize(:lower)}
              end
            end
            super
          end
        end
      end

      def root_name
        self._root = self.class.name.demodulize.underscore.sub(/_serializer$/, '').camelize(:lower).to_sym if !self._root && !self.class.name.blank?
        super
      end

    end
  end
end