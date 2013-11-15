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

        self.serializer_class = @options[:serializer]
      end

      attr_reader :name, :embed_ids, :embed_objects, :serializer_class
      attr_accessor :embed_in_root, :embed_key, :key, :embedded_key, :options
      alias embed_ids? embed_ids
      alias embed_objects? embed_objects
      alias embed_in_root? embed_in_root

      def serializer_class=(serializer)
        @serializer_class = serializer.is_a?(String) ? serializer.constantize : serializer
      end

      def embed=(embed)
        @embed_ids     = embed == :id || embed == :ids
        @embed_objects = embed == :object || embed == :objects
      end

      def build_serializer(object, convert_type = nil)
        @serializer_class ||= Serializer.serializer_for(object) || DefaultSerializer
        @serializer_class.new(object, @options.merge(:convert_type => convert_type))
      end

      class HasOne < Association
        def initialize(*args)
          super
          @key  ||= "#{name}_id"
        end
      end

      class HasMany < Association
        def initialize(*args)
          super
          @key ||= "#{name.singularize}_ids"
        end
      end
    end
  end
end
