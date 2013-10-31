require 'active_model/default_serializer'
require 'active_model/serializer'

module ActiveModel
  class Serializer
    class Association
      def initialize(name, options={})
        if options.has_key?(:include)
          ActiveSupport::Deprecation.warn <<-WARN
** Notice: include was renamed to embed_in_root. **
          WARN
        end

        @name          = name.to_s
        @options       = options
        self.embed     = options.fetch(:embed)   { CONFIG.embed }
        @embed_in_root = options.fetch(:embed_in_root) { options.fetch(:include) { CONFIG.embed_in_root } }
        @embed_key     = options[:embed_key] || :id
        @key           = options[:key]

        self.serializer_class = @options[:serializer]
      end

      attr_reader :name, :embed_ids, :embed_objects, :serializer_class
      attr_accessor :embed_in_root, :embed_key, :key, :embedded_key, :options
      alias embed_ids? embed_ids
      alias embed_objects? embed_objects
      alias embed_in_root? embed_in_root

      def serializer_class=(serializer)
        @serializer_class = serializer.is_a?(String) ? serializer.constantize : serializer

        if @serializer_class && !(@serializer_class <= ArraySerializer)
          @options.merge!(each_serializer: @serializer_class)
          @serializer_class = ArraySerializer
        else
          @serializer_class ||= ArraySerializer
        end
      end

      def embed=(embed)
        @embed_ids     = embed == :id || embed == :ids
        @embed_objects = embed == :object || embed == :objects
      end

      def build_serializer(object)
        @serializer_class.new(Array(object), @options)
      end

      class HasOne < Association
        def initialize(name, *args)
          super
          @embedded_key = "#{@options[:root] || name}".pluralize
          @key ||= "#{name}_id"
        end
      end

      class HasMany < Association
        def initialize(name, *args)
          super
          @embedded_key = @options[:root] || name
          @key ||= "#{name.to_s.singularize}_ids"
        end
      end
    end
  end
end
