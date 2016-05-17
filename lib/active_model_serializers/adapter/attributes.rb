module ActiveModelSerializers
  module Adapter
    class Attributes < Base
      def initialize(serializer, options = {})
        super
        @include_tree = ActiveModel::Serializer::IncludeTree.from_include_args(options[:include] || '*')
        @cached_attributes = options[:cache_attributes] || {}
      end

      def serializable_hash(options = nil)
        options = serialization_options(options)

        if serializer.respond_to?(:each)
          serializable_hash_for_collection(options)
        else
          serializable_hash_for_single_resource(options)
        end
      end

      private

      def serializable_hash_for_collection(options)
        cache_attributes

        serializer.map { |s| Attributes.new(s, instance_options).serializable_hash(options) }
      end

      def serializable_hash_for_single_resource(options)
        resource = resource_object_for(options)
        relationships = resource_relationships(options)
        resource.merge(relationships)
      end

      def resource_relationships(options)
        relationships = {}
        serializer.associations(@include_tree).each do |association|
          relationships[association.key] ||= relationship_value_for(association, options)
        end

        relationships
      end

      def relationship_value_for(association, options)
        return association.options[:virtual_value] if association.options[:virtual_value]
        return unless association.serializer && association.serializer.object

        opts = instance_options.merge(include: @include_tree[association.key])
        relationship_value = Attributes.new(association.serializer, opts).serializable_hash(options)

        if association.options[:polymorphic] && relationship_value
          polymorphic_type = association.serializer.object.class.name.underscore
          relationship_value = { type: polymorphic_type, polymorphic_type.to_sym => relationship_value }
        end

        relationship_value
      end

      # Set @cached_attributes
      def cache_attributes
        return if @cached_attributes.present?

        @cached_attributes = ActiveModel::Serializer.cache_read_multi(serializer, self, @include_tree)
      end

      def resource_object_for(options)
        if serializer.class.cache_enabled?
          @cached_attributes.fetch(serializer.cache_key(self)) do
            serializer.cached_fields(options[:fields], self)
          end
        else
          serializer.cached_fields(options[:fields], self)
        end
      end
    end
  end
end
