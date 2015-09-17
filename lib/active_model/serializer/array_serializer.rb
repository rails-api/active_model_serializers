module ActiveModel
  class Serializer
    class ArraySerializer
      NoSerializationError = Class.new(StandardError)
      include Enumerable
      delegate :each, to: :@serializers

      attr_reader :object, :root, :meta, :meta_key

      def initialize(resources, options = {})
        @root = options[:root]
        @object = resources
        @serializers = resources.map do |resource|
          serializer_class = options.fetch(:serializer) {
            ActiveModel::Serializer.serializer_for(resource)
          }

          if serializer_class.nil?
            fail NoSerializationError, "No serialization found for resource: #{resource.inspect}"
          else
            serializer_class.new(resource, options.except(:serializer))
          end
        end
        @meta     = options[:meta]
        @meta_key = options[:meta_key]
      end

      def json_key
        key = root || @serializers.first.try(:json_key) || object.try(:name).try(:underscore)
        key.try(:pluralize)
      end

      def paginated?
        object.respond_to?(:current_page) &&
          object.respond_to?(:total_pages) &&
          object.respond_to?(:size)
      end
    end
  end
end
