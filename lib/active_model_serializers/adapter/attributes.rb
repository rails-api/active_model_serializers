module ActiveModelSerializers
  module Adapter
    class Attributes < Base
      def initialize(serializer, options = {})
        super
      end

      def serializable_hash(options = nil)
        options = serialization_options(options)

        if serializer.respond_to?(:each)
          serializable_hash_for_collection(serializer, options)
        else
          serializable_hash_for_single_resource(serializer, instance_options, options)
        end
      end

      private

      def serializable_hash_for_collection(serializers, options)
        include_directive = ActiveModel::Serializer.include_directive_from_options(instance_options)
        instance_options[:cached_attributes] ||= ActiveModel::Serializer.cache_read_multi(serializers, self, include_directive)
        instance_opts = instance_options.merge(include_directive: include_directive)
        serializers.map do |serializer|
          serializable_hash_for_single_resource(serializer, instance_opts, options)
        end
      end

      def serializable_hash_for_single_resource(serializer, instance_options, options)
        options[:include_directive] ||= ActiveModel::Serializer.include_directive_from_options(instance_options)
        serializer.serializable_hash_for_single_resource(instance_options, options, self)
      end
    end
  end
end
