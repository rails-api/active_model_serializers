module ActiveModel
  class Serializer
    # @api private
    class BelongsToReflection < SingularReflection
      def macro
        :belongs_to
      end
    end
  end
end
