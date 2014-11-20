module ActiveModel
  class Serializer
    class ArraySerializer
      include Enumerable
      delegate :each, to: :@objects

      attr_reader :controller, :options

      def initialize(objects, options = {}, controller = nil)
        # default_options = controller ? controller.send(:default_serializer_options) || {} : {}
        # @options = default_options.merge(options || {})
        @options = options
        @controller = controller
        @objects = objects.map do |object|
          serializer_class = options.fetch(
            :serializer,
            ActiveModel::Serializer.serializer_for(object)
          )
          serializer_class.new(object, @options, @controller)
        end
      end

      def json_key
        @objects.first.json_key.pluralize if @objects.first && @objects.first.json_key
      end

      def root=(root)
        @objects.first.root = root if @objects.first
      end
    end
  end
end
