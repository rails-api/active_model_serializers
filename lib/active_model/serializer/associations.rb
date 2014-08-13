require 'active_model/default_serializer'

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
        self.embed     = options.fetch(:embed) { CONFIG.embed }
        @embed_in_root = options.fetch(:embed_in_root) { options.fetch(:include) { CONFIG.embed_in_root } }
        @key_format    = options.fetch(:key_format) { CONFIG.key_format }
        @embed_key     = options[:embed_key] || :id
        @key           = options[:key]
        @embedded_key  = options[:root] || name
        @embed_in_root_key = options.fetch(:embed_in_root_key) { CONFIG.embed_in_root_key }
        @embed_namespace = options.fetch(:embed_namespace) { CONFIG.embed_namespace }

        serializer = @options[:serializer]
        @serializer_from_options = serializer.is_a?(String) ? serializer.constantize : serializer
      end

      attr_reader :name, :embed_ids, :embed_objects
      attr_accessor :embed_in_root, :embed_key, :key, :embedded_key, :root_key, :serializer_from_options, :options, :key_format, :embed_in_root_key, :embed_namespace
      alias embed_ids? embed_ids
      alias embed_objects? embed_objects
      alias embed_in_root? embed_in_root
      alias embed_in_root_key? embed_in_root_key
      alias embed_namespace? embed_namespace

      def embed=(embed)
        @embed_ids     = embed == :id || embed == :ids
        @embed_objects = embed == :object || embed == :objects
      end

      def serializer_from_object(object)
        Serializer.serializer_for(object)
      end

      def default_serializer
        DefaultSerializer
      end

      def build_serializer(object, options = {})
        serializer_class(object).new(object, options.merge(self.options))
      end

      class HasOne < Association
        def initialize(name, *args)
          super
          @root_key = @embedded_key.to_s.pluralize
          @key ||= "#{name}_id"
        end

        def serializer_class(object)
          serializer_from_options || serializer_from_object(object) || default_serializer
        end

        def build_serializer(object, options = {})
          options[:_wrap_in_array] = embed_in_root?
          super
        end
      end

      class HasMany < Association
        def initialize(name, *args)
          super
          @root_key = @embedded_key
          @key ||= "#{name.to_s.singularize}_ids"
        end

        def serializer_class(object)
          if use_array_serializer?
            ArraySerializer
          else
            serializer_from_options
          end
        end

        def options
          if use_array_serializer?
            { each_serializer: serializer_from_options }.merge! super
          else
            super
          end
        end

        private

        def use_array_serializer?
          !serializer_from_options ||
            serializer_from_options && !(serializer_from_options <= ArraySerializer)
        end
      end
    end
  end
end
