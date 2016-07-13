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
        def type(type)
          self._type = type && type.to_s
        end
      end
    end
  end
end
