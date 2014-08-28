module ActiveModel
  class Serializer
    class ArraySerializer < Serializer
      def initialize(object)
        @object = object
      end

      def attributes(options = {})
        object.map do |item|
          serializer_class = ActiveModel::Serializer.serializer_for(item)
          serializer_class.new(item)
        end
      end
    end
  end
end
