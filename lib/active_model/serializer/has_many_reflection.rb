module ActiveModel
  class Serializer
    # @api private
    class HasManyReflection < CollectionReflection
      def macro
        :has_many
      end
    end
  end
end
