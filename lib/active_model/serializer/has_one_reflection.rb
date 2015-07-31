module ActiveModel
  class Serializer
    # @api private
    class HasOneReflection < SingularReflection
      def macro
        :has_one
      end
    end
  end
end
