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

      def cached_name
        @cached_name ||= self.class.name.demodulize.underscore
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

      class << self
        # Sets the default transform for the adapter.
        #
        # @return [Symbol] the default transform for the adapter
        def default_key_transform
          :unaltered
        end

        # Determines the transform to use in order of precedence:
        #   adapter option, global config, adapter default.
        #
        # @param options [Object]
        # @return [Symbol] the transform to use
        def transform(options)
          return options[:key_transform] if options && options[:key_transform]
          ActiveModelSerializers.config.key_transform || default_key_transform
        end

        # Transforms the casing of the supplied value.
        #
        # @param value [Object] the value to be transformed
        # @param options [Object] serializable resource options
        # @return [Symbol] the default transform for the adapter
        def transform_key_casing!(value, options)
          KeyTransform.send(transform(options), value)
        end
      end
    end
  end
end
