require 'active_model/default_serializer'
require 'active_model/serializer'
require 'active_model/serializer/association/is_polymorphic'
require 'active_model/serializer/association/has_one'
require 'active_model/serializer/association/has_many'
require 'active_model/serializer/association/has_many_polymorphic'

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

      def build_serializer(object)
        @serializer_class ||= Serializer.serializer_for(object) || DefaultSerializer
        @serializer_class.new(object, @options)
      end

      def serialize(object)
        serialize_single(object)
      end

      def serialize_ids(object)
        serialize_id(object)
      end

      protected

      def serialize_single(object)
        object ? build_serializer(object).serializable_hash : nil
      end

      def serialize_id(object)
        object ? object.read_attribute_for_serialization(embed_key) : nil
      end
    end
  end
end
