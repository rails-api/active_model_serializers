module ActiveModel
  class Serializer
    class Association
      def initialize(name, options={})
        @name          = name
        @options       = options

        self.embed = options[:embed]
        @embed_key = options[:embed_key] || :id
        @include   = options[:include]

        serializer = @options[:serializer]
        @serializer_class = serializer.is_a?(String) ? serializer.constantize : serializer
      end

      attr_reader :name, :embed_ids, :embed_objects, :embed_key, :include
      alias embed_ids? embed_ids
      alias embed_objects? embed_objects
      alias include? include

      def embed=(embed)
        @embed_ids     = embed == :id || embed == :ids
        @embed_objects = embed == :object || embed == :objects
      end

      def build_serializer(object)
        @serializer_class ||= Serializer.serializer_for(object)

        if @serializer_class
          @serializer_class.new(object, @options)
        else
          object
        end
      end

      class HasOne < Association
        def key
          "#{name}_id"
        end
      end
    end
  end
end
