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
        @polymorphic   = options.fetch(:polymorphic, false)
        @embed_in_root = options.fetch(:embed_in_root) { options.fetch(:include) { CONFIG.embed_in_root } }
        @embed_key     = options[:embed_key] || :id
        @key           = options[:key]
        @embedded_key  = options[:root] || name

        self.serializer_class = @options[:serializer]
      end

      attr_reader :name, :embed_ids, :embed_objects, :serializer_class, :polymorphic
      attr_accessor :embed_in_root, :embed_key, :key, :embedded_key, :options
      alias embed_ids? embed_ids
      alias embed_objects? embed_objects
      alias embed_in_root? embed_in_root
      alias polymorphic? polymorphic

      def type_name(object)
        object.class.to_s.demodulize.underscore.to_sym
      end

      def serializer_class=(serializer)
        @serializer_class = serializer.is_a?(String) ? serializer.constantize : serializer
      end

      def embed=(embed)
        @embed_ids     = embed == :id || embed == :ids
        @embed_objects = embed == :object || embed == :objects
      end

      def build_serializer(object)
        if polymorphic? || !@serializer_class
          serializer_class = Serializer.serializer_for(object) || DefaultSerializer
        end
        @serializer_class ||= serializer_class unless polymorphic
        (@serializer_class || serializer_class).new(object, @options)
      end

      def serialize(associated_data)
        if associated_data.respond_to?(:to_ary)
          associated_data.map do |elem|
            result = build_serializer(elem).serializable_hash
            result.merge!(type: type_name(elem)) if polymorphic? && result
            result
          end
        else
          result = build_serializer(associated_data).serializable_hash
          result.merge!(type: type_name(elem)) if polymorphic?
          is_a?(Association::HasMany) ? [result] : result
        end
      end

      def serialize_ids(associated_data)
        if associated_data.respond_to?(:to_ary)
          associated_data.map { |elem| serialize_id(elem) }
        elsif associated_data
          associated_data.read_attribute_for_serialization(embed_key)
        end
      end

      private

      def serialize_id(elem)
        id = elem.read_attribute_for_serialization(embed_key)
        if polymorphic?
          { id: id, type: type_name(elem) }
        else
          id
        end
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
