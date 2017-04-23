module ActiveModel
  class Serializer
    # @api private
    class HasManyReflection < CollectionReflection
      def to_many?
        true
      end
    end
  end
end
