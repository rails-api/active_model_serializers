module ActiveModel
  class Serializer
    class ArraySerializer
      NoSerializerError = Class.new(StandardError)
      include Enumerable
      delegate :each, to: :@objects

      attr_reader :meta, :meta_key

      def initialize(objects, options = {})
        @resource = objects
        @objects  = objects.map do |object|
          serializer_class = options.fetch(
            :serializer,
            ActiveModel::Serializer.serializer_for(object)
          )

          if serializer_class.nil?
            fail NoSerializerError, "No serializer found for object: #{object.inspect}"
          else
            serializer_class.new(object, options.except(:serializer))
          end
        end
        @meta     = options[:meta]
        @meta_key = options[:meta_key]
      end

      def json_key
        if @objects.first
          @objects.first.json_key.pluralize
        else
          @resource.name.underscore.pluralize if @resource.try(:name)
        end
      end

      def root=(root)
        @objects.first.root = root if @objects.first
      end
    end
  end
end
