# frozen_string_literal: true

module ActiveModel
  class Serializer
    # @api private
    class HasManyReflection < Reflection
      def collection?
        true
      end
    end
  end
end
