module ActiveModel
  class Serializer
    class LazyAssociation < Field

      def serializer
        options[:serializer]
      end

      def include_data?
        options[:include_data]
      end

      def virtual_value
        options[:virtual_value]
      end

      def reflection
        options[:reflection]
      end
    end
  end
end
