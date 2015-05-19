module ActiveModel
  class Serializer
    class ArraySerializer
      include Enumerable
      delegate :each, to: :@objects

      attr_accessor :meta, :meta_key, :root

      def initialize(objects, options = {})
        @root = options[:root]
        options.merge!(root: nil)

        @objects = objects.map do |object|
          serializer_class = options.fetch(
            :serializer,
            ActiveModel::Serializer.serializer_for(object)
          )
          serializer_class.new(object, options.except(:serializer))
        end
        @meta     = options[:meta]
        @meta_key = options[:meta_key]
      end

      def json_key
        if root == true && @objects.first
          @objects.first.class.root_name
        else
          root
        end
      end
    end
  end
end
