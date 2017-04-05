module ActiveModelSerializers
  module Adapter
    class Json < Base
      attr_reader :fieldset

      def initialize(serializer, options = {})
        @fieldset = options[:fieldset] || ActiveModel::Serializer::Fieldset.new(options.delete(:fields))
        super
      end

      def serializable_hash(options = nil)
        options = serialization_options(options)
        options[:fields] ||= fields
        serialized_hash = { root => Attributes.new(serializer, instance_options).serializable_hash(options) }
        serialized_hash[meta_key] = meta unless meta.blank?

        self.class.transform_key_casing!(serialized_hash, instance_options)
      end

      def fields
        fieldset && fieldset.fields_for(serializer.json_key)
      end

      def meta
        instance_options.fetch(:meta, nil)
      end

      def meta_key
        instance_options.fetch(:meta_key, 'meta'.freeze)
      end
    end
  end
end
