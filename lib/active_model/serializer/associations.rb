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
        @embedded_key  = options[:root] || name

        serializer = @options[:serializer]
        @serializer_class = serializer.is_a?(String) ? serializer.constantize : serializer
      end

      attr_reader :name, :embed_ids, :embed_objects
      attr_accessor :embed_in_root, :embed_key, :key, :embedded_key, :root_key, :serializer_class, :options
      alias embed_ids? embed_ids
      alias embed_objects? embed_objects
      alias embed_in_root? embed_in_root

      def embed=(embed)
        @embed_ids     = embed == :id || embed == :ids
        @embed_objects = embed == :object || embed == :objects
      end

      def build_serializer(object, options = {})
        @serializer_class.new(object, options.merge(@options))
      end

      private

      def use_array_serializer!
        @options.merge!(each_serializer: @serializer_class)
        @serializer_class = ArraySerializer
      end

      class HasOne < Association
        def initialize(name, *args)
          super
          @root_key = @embedded_key.to_s.pluralize
          @key ||= "#{name}_id"
        end

        def build_serializer(object, options = {})
          if object.respond_to?(:to_ary) && !(@serializer_class && @serializer_class <= ArraySerializer)
            use_array_serializer!
          else
            @serializer_class ||= Serializer.serializer_for(object) || DefaultSerializer
          end

          super
        end
      end

      class HasMany < Association
        def initialize(name, *args)
          super
          @root_key = @embedded_key
          @key ||= "#{name.to_s.singularize}_ids"
        end

        def build_serializer(object, options = {})
          if @serializer_class && !(@serializer_class <= ArraySerializer)
            use_array_serializer!
          else
            @serializer_class ||= ArraySerializer
          end

          super
        end
      end
    end
  end
end
