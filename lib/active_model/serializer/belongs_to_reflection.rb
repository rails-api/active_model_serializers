module ActiveModel
  class Serializer
    # @api private
    class BelongsToReflection < Reflection
      # @api private
      def foreign_key_on
        :self
      end

      def include_resource_identifier?
        ActiveModelSerializers.config.include_belongs_to_resource_identifier == true
      end
    end
  end
end
