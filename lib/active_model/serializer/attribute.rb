module ActiveModel
  class Serializer
    Attribute = Struct.new(:name, :block) do
      def value(serializer)
        if block
          serializer.instance_eval(&block)
        else
          serializer.read_attribute_for_serialization(name)
        end
      end
    end
  end
end
