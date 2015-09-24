module ActiveModel
  class Serializer
    class ArraySerializer
      NoSerializerError = Class.new(StandardError)
      include Enumerable
      delegate :each, to: :@serializers

      attr_reader :object, :root, :meta, :meta_key, :parent_serializer, :root_serializer

      def initialize(resources, options = {})
        @root = options[:root]
        @object = resources
        @parent_serializer = options[:parent_serializer]
        @root_serializer = @parent_serializer.try(:root_serializer)
        lookup_serializer = (@parent_serializer && @parent_serializer.class) || ActiveModel::Serializer
        @serializers = resources.map do |resource|
          serializer_class = options.fetch(:serializer) { lookup_serializer.serializer_for(resource) }

          if serializer_class.nil?
            fail NoSerializerError, "No serializer found for resource: #{resource.inspect}"
          else
            serializer_options = options.except(:serializer)
            serializer_options.merge!(parent_serializer: @parent_serializer) if @parent_serializer
            serializer_class.new(resource, serializer_options)
          end
        end
        @meta     = options[:meta]
        @meta_key = options[:meta_key]
      end

      def json_key
        key = root || serializers.first.try(:json_key) || object.try(:name).try(:underscore)
        key.try(:pluralize)
      end

      def paginated?
        object.respond_to?(:current_page) &&
          object.respond_to?(:total_pages) &&
          object.respond_to?(:size)
      end

      private # rubocop:disable Lint/UselessAccessModifier

      ActiveModelSerializers.silence_warnings do
        attr_reader :serializers
      end
    end
  end
end
