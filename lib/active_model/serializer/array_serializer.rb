module ActiveModel
  class Serializer
    class ArraySerializer < Serializer
      include Enumerable
      delegate :each, to: :object

      def initialize(object)
        @object = object.map do |item|
          serializer_class = ActiveModel::Serializer.serializer_for(item)
          serializer_class.new(item)
        end
      end
    end
  end
end
