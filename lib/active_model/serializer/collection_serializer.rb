module ActiveModel
  class Serializer
    class CollectionSerializer
      NoSerializerError = Class.new(StandardError)
      include Enumerable
      delegate :each, to: :@serializers

      attr_reader :object, :root

      def initialize(resources, options = {})
        @root = options[:root]
        @object = resources
        @serializers = resources.map do |resource|
          serializer_context_class = options.fetch(:serializer_context_class, ActiveModel::Serializer)
          serializer_class = options.fetch(:serializer) { serializer_context_class.serializer_for(resource) }

          if serializer_class.nil?
            fail NoSerializerError, "No serializer found for resource: #{resource.inspect}"
          else
            serializer_class.new(resource, options.except(:serializer))
          end
        end
      end

      def json_key
        root || derived_root
      end

      def paginated?
        object.respond_to?(:current_page) &&
          object.respond_to?(:total_pages) &&
          object.respond_to?(:size)
      end

      protected

      attr_reader :serializers

      private

      def derived_root
        key = serializers.first.try(:json_key) || object.try(:name).try(:underscore)
        key.try(:pluralize)
      end
    end
  end
end
