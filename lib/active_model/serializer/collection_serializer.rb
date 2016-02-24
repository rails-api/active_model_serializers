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

        serializer_context_class = options.fetch(:serializer_context_class, ActiveModel::Serializer)

        if resources.blank? && options[:serializer]
          @each_serializer = options[:serializer]
        end

        @serializers = resources.map do |resource|
          serializer_class = options.fetch(:serializer) { serializer_context_class.serializer_for(resource) }

          if serializer_class.nil? # rubocop:disable Style/GuardClause
            fail NoSerializerError, "No serializer found for resource: #{resource.inspect}"
          else
            serializer_class.new(resource, options.except(:serializer))
          end
        end
      end

      def success?
        true
      end

      def json_key
        root || derived_root || guess_root || default_root
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
        serializers.first.try(:json_key).try(:pluralize)
      end

      def default_root
        object.try(:name).try(:underscore).try(:pluralize)
      end

      def guess_root
        @each_serializer.try(:allocate).try(:json_key).try(:pluralize)
      end
    end
  end
end
