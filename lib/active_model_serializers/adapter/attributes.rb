module ActiveModelSerializers
  module Adapter
    class Attributes < Base
      def initialize(serializer, options = {})
        super
        @include_tree = ActiveModel::Serializer::IncludeTree.from_include_args(options[:include] || '*')
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
        serializer.map { |s| Attributes.new(s, instance_options).serializable_hash(options) }
      end

      def serializable_hash_for_single_resource(options)
        resource = serializer.cached_attributes(options[:fields], self)
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
        Attributes.new(association.serializer, opts).serializable_hash(options)
      end
    end
  end
end
