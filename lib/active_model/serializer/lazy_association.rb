module ActiveModel
  class Serializer
    # @api private
    LazyAssociation = Struct.new(:reflection, :association_options) do
      REFLECTION_OPTIONS = %i(key links polymorphic meta serializer virtual_value namespace).freeze

      delegate :collection?, to: :reflection

      def reflection_options
        @reflection_options ||= reflection.options.dup.reject { |k, _| !REFLECTION_OPTIONS.include?(k) }
      end

      def object
        @object ||= reflection.value(
          association_options.fetch(:parent_serializer),
          association_options.fetch(:include_slice)
        )
      end
      alias_method :eval_reflection_block, :object

      def include_data?
        eval_reflection_block if reflection.block
        reflection.include_data?(
          association_options.fetch(:include_slice)
        )
      end

      # @return [ActiveModel::Serializer, nil]
      def serializer
        return @serializer if defined?(@serializer)
        if serializer_class
          serialize_object!(object)
        elsif !object.nil? && !object.instance_of?(Object)
          cached_result[:virtual_value] = object
        end
        @serializer = cached_result[:serializer]
      end

      def virtual_value
        cached_result[:virtual_value] || reflection_options[:virtual_value]
      end

      # NOTE(BF): Kurko writes:
      # 1. This class is doing a lot more than it should. It has business logic (key/meta/links) and
      #   it also looks like a factory (serializer/serialize_object/instantiate_serializer/serializer_class).
      #   It's hard to maintain classes that you can understand what it's really meant to be doing,
      #   so it ends up having all sorts of methods.
      #   Perhaps we could replace all these methods with a class called... Serializer.
      #   See how association is doing the job a serializer again?
      # 2. I've seen code like this in many other places.
      #   Perhaps we should just have it all in one place: Serializer.
      #   We already have a class called Serializer, I know,
      #   and that is doing things that are not responsibility of a serializer.
      def serializer_class
        return @serializer_class if defined?(@serializer_class)
        serializer_for_options = { namespace: namespace }
        serializer_for_options[:serializer] = reflection_options[:serializer] if reflection_options.key?(:serializer)
        @serializer_class = association_options.fetch(:parent_serializer).class.serializer_for(object, serializer_for_options)
      end

      private

      def cached_result
        @cached_result ||= {}
      end

      def serialize_object!(object)
        if collection?
          if (serializer = instantiate_collection_serializer(object)).nil?
            # BUG: per #2027, JSON API resource relationships are only id and type, and hence either
            # *require* a serializer or we need to be a little clever about figuring out the id/type.
            # In either case, returning the raw virtual value will almost always be incorrect.
            #
            # Should be reflection_options[:virtual_value] or adapter needs to figure out what to do
            # with an object that is non-nil and has no defined serializer.
            cached_result[:virtual_value] = object.try(:as_json) || object
          else
            cached_result[:serializer] = serializer
          end
        else
          cached_result[:serializer] = instantiate_serializer(object)
        end
      end

      # NOTE(BF): This serializer throw/catch should only happen when the serializer is a collection
      # serializer.  This is a good reason for the reflection to have a to_many? type method.
      def instantiate_serializer(object)
        serializer_options = association_options.fetch(:parent_serializer_options).except(:serializer)
        serializer_options[:serializer_context_class] = association_options.fetch(:parent_serializer).class
        serializer = reflection_options.fetch(:serializer, nil)
        serializer_options[:serializer] = serializer if serializer
        serializer_class.new(object, serializer_options)
      end

      def instantiate_collection_serializer(object)
        serializer = catch(:no_serializer) do
          instantiate_serializer(object)
        end
        serializer
      end

      def namespace
        reflection_options[:namespace] ||
          association_options.fetch(:parent_serializer_options)[:namespace]
      end
    end
  end
end
