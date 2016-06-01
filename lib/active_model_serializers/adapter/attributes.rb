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

      def include_directive_from_options(options)
        if options[:include_directive]
          options[:include_directive]
        elsif options[:include]
          JSONAPI::IncludeDirective.new(options[:include], allow_wildcard: true)
        else
          ActiveModelSerializers.default_include_directive
        end
      end

      def serializable_hash_for_collection(serializers, options)
        include_directive = include_directive_from_options(instance_options)
        instance_options[:cached_attributes] ||= ActiveModel::Serializer.cache_read_multi(serializers, self, include_directive)
        instance_opts = instance_options.merge(include_directive: include_directive)
        serializers.map do |serializer|
          serializable_hash_for_single_resource(serializer, instance_opts, options)
        end
      end

      def serializable_hash_for_single_resource(serializer, instance_options, options)
        options[:include_directive] ||= include_directive_from_options(instance_options)
        cached_attributes = instance_options[:cached_attributes] ||= {}
        resource = serializer.cached_attributes(options[:fields], cached_attributes, self)
        relationships = resource_relationships(serializer, options)
        resource.merge(relationships)
      end

      def resource_relationships(serializer, options)
        relationships = {}
        include_directive = options.fetch(:include_directive)
        serializer.associations(include_directive).each do |association|
          relationships[association.key] ||= relationship_value_for(association, options)
        end

        relationships
      end

      def relationship_value_for(association, options)
        return association.options[:virtual_value] if association.options[:virtual_value]
        return unless association.serializer && association.serializer.object

        include_directive = options.fetch(:include_directive)
        opts = instance_options.merge(include_directive: include_directive[association.key])
        relationship_value = Attributes.new(association.serializer, opts).serializable_hash(options)

        if association.options[:polymorphic] && relationship_value
          polymorphic_type = association.serializer.object.class.name.underscore
          relationship_value = { type: polymorphic_type, polymorphic_type.to_sym => relationship_value }
        end

        relationship_value
      end
    end
  end
end
