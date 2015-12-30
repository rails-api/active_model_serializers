module ActiveModel
  class Serializer
    Attribute = Struct.new(:name, :options, :block) do
      def value(serializer)
        if block
          serializer.instance_eval(&block)
        else
          serializer.read_attribute_for_serialization(name)
        end
      end

      def included?(serializer)
        case condition
        when :if
          serializer.public_send(condition)
        when :unless
          !serializer.public_send(condition)
        else
          true
        end
      end

      private

      def condition_type
        if options.key?(:if)
          :if
        elsif options.key?(:unless)
          :unless
        else
          :none
        end
      end

      def condition
        options[condition_type]
      end
    end
  end
end
