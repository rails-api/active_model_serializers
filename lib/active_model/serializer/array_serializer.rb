module ActiveModel
  class Serializer
    class ArraySerializer
      include Enumerable
      delegate :each, to: :@objects

      def initialize(objects, options = {})
        @objects = objects.map do |object|
          serializer_class = ActiveModel::Serializer.serializer_for(object)
          serializer_class.new(object)
        end
      end
    end
  end
end
