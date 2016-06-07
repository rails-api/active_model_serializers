module ActiveModel
  class Serializer
    module Type
      extend ActiveSupport::Concern

      included do
        with_options instance_writer: false, instance_reader: true do |serializer|
          serializer.class_attribute :_type # @api private
        end

        extend ActiveSupport::Autoload
      end

      module ClassMethods
        # Set the JSON API type of a serializer.
        # @example
        #   class AdminAuthorSerializer < ActiveModel::Serializer
        #     type 'authors'
        #
        # @example
        # TODO: actually do block, not Proc
        #   class AdminAuthorSerializer < ActiveModel::Serializer
        #     type { |object| object.class.name }
        def type(type = nil, &block)
          type = block if block_given?
          return unless type

          self._type = if type.respond_to?(:call) && type.arity == 1
                         type
                       else
                         type.to_s
                       end
        end
      end
    end
  end
end
