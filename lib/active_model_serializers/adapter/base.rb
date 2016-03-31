require 'active_model_serializers/key_transform'

module ActiveModelSerializers
  module Adapter
    class Base
      # Automatically register adapters when subclassing
      def self.inherited(subclass)
        ActiveModelSerializers::Adapter.register(subclass)
      end

      attr_reader :serializer, :instance_options

      def initialize(serializer, options = {})
        @serializer = serializer
        @instance_options = options
      end

      def serializable_hash(_options = nil)
        fail NotImplementedError, 'This is an abstract method. Should be implemented at the concrete adapter.'
      end

      def as_json(options = nil)
        hash = serializable_hash(options)
        include_meta(hash)
        hash
      end

      def fragment_cache(cached_hash, non_cached_hash)
        non_cached_hash.merge cached_hash
      end

      def cache_check(serializer)
        CachedSerializer.new(serializer).cache_check(self) do
          yield
        end
      end

      private

      def meta
        instance_options.fetch(:meta, nil)
      end

      def meta_key
        instance_options.fetch(:meta_key, 'meta'.freeze)
      end

      def root
        serializer.json_key.to_sym if serializer.json_key
      end

      def include_meta(json)
        json[meta_key] = meta unless meta.blank?
        json
      end

      def default_key_transform
        :unaltered
      end

      # Determines the transform to use in order of precedence:
      #   serialization context, global config, adapter default.
      #
      # @param serialization_context [Object] the SerializationContext
      # @return [Symbol] the transform to use
      def key_transform(serialization_context)
        serialization_context.key_transform ||
        ActiveModelSerializers.config.key_transform ||
        default_key_transform
      end

      def transform_key_casing!(value, serialization_context)
        return value unless serialization_context
        transform = key_transform(serialization_context)
        KeyTransform.send(transform, value)
      end
    end
  end
end
