require 'active_model/default_serializer'
require 'active_model/serializer'

module ActiveModel
  class Serializer
    class Association
      attr_accessor :name, :configuration

      def initialize(name, options = {}, configuration = nil)
        if options.has_key?(:include)
          ActiveSupport::Deprecation.warn <<-WARN
** Notice: include was renamed to embed_in_root. **
          WARN
          options[:embed_in_root] = options.fetch(:embed_in_root) { options.delete(:include) }
        end

        @name          = name.to_s
        @configuration = AssociationConfiguration.new configuration, options
      end

      extend Forwardable
      def_delegators :configuration, :embed_ids, :embed_objects, :embed, :embed_in_root, :embed_key, :key, :root, :serializer

      def embedded_key
        root || name
      end

      def embed=(embed)
        @embed_ids     = embed == :id || embed == :ids
        @embed_objects = embed == :object || embed == :objects
      end

      def serializer_from_options
        configuration.serializer
      end

      def serializer_from_object(object)
        Serializer.serializer_for(object)
      end

      def default_serializer
        DefaultSerializer
      end

      def build_serializer(object, options = {})
        serializer_class(object).new(object, options, configuration)
      end

      class HasOne < Association
        def root_key
          embedded_key.to_s.pluralize
        end

        def key
          "#{name}_id"
        end

        def serializer_class(object)
          serializer_from_options || serializer_from_object(object) || default_serializer
        end

        def build_serializer(object, options = {})
          super.tap do |instance|
            instance.configuration.wrap_in_array = embed_in_root
          end
        end
      end

      class HasMany < Association
        alias_method :root_key, :embedded_key

        def key
          "#{name.to_s.singularize}_ids"
        end

        def serializer_class(object)
          if use_array_serializer?
            ArraySerializer
          else
            serializer_from_options
          end
        end

        def build_serializer(object, options = {})
          if use_array_serializer?
            super object, { each_serializer: serializer_from_options }.merge!(options), configuration
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
