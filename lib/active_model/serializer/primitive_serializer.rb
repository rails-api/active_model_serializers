module ActiveModel
  class Serializer
    class PrimitiveSerializer < Serializer
      def self.can_serialize?(value)
        [:to_str, :to_int, :to_hash].detect { |meth|
          value.respond_to?(meth)
        } || value.is_a?(Symbol)
      end

      def attributes(*)
        object
      end
    end
  end
end
