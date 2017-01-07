module ActiveModel
  class Serializer
    class Null < Serializer
      # :nocov:
      def attributes(*)
        {}
      end

      def associations(*)
        {}
      end

      def serializable_hash(*)
        {}
      end
      # :nocov:
    end
  end
end
