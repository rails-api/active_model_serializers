module ActiveModel
  class Serializer
    class ArraySerializer < Serializer
      def initialize(object)
        @object = object
      end
    end
  end
end
