module ActiveModel
  class Serializer
    module Meta
      extend ActiveSupport::Concern

      included do
        with_options instance_writer: false, instance_reader: true do |serializer|
          serializer.class_attribute :_meta # @api private
        end

        extend ActiveSupport::Autoload
      end

      module ClassMethods
        # Set the JSON API meta attribute of a serializer.
        # @example
        #   class AdminAuthorSerializer < ActiveModel::Serializer
        #     meta { stuff: 'value' }
        # @example
        #     meta do
        #       { comment_count: object.comments.count }
        #     end
        def meta(value = nil, &block)
          self._meta = block || value
        end
      end
    end
  end
end
