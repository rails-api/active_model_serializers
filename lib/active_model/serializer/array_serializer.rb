module ActiveModel
  class Serializer
    class ArraySerializer
      NoSerializerError = Class.new(StandardError)
      include Enumerable
      delegate :each, to: :@objects

      attr_reader :root, :meta, :meta_key

      def initialize(objects, options = {})
        @root = options[:root]
        @resource = objects
        @objects  = objects.map do |object|
          serializer_class = options.fetch(
            :serializer,
            ActiveModel::Serializer.serializer_for(object)
          )

          if serializer_class.nil?
            fail NoSerializerError, "No serializer found for object: #{object.inspect}"
          else
            serializer_class.new(object, options.except(:serializer).merge(listed: true))
          end
        end
        @meta     = options[:meta]
        @meta_key = options[:meta_key]
      end

      def json_key
        key = root || @objects.first.try(:json_key) || @resource.try(:name).try(:underscore)
        key.try(:pluralize)
      end
    end
  end
end
