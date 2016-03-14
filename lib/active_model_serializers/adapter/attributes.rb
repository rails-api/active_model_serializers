module ActiveModelSerializers
  module Adapter
    class Attributes < Base
      def initialize(serializer, options = {})
        super
        @include_tree = ActiveModel::Serializer::IncludeTree.from_include_args(options[:include] || '*')
        @cached_attributes = options[:cache_attributes] || {}
      end

      def serializable_hash(options = nil)
        options ||= {}

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

      # Read cache from cache_store
      # @return [Hash]
      def cache_read_multi
        return {} if ActiveModelSerializers.config.cache_store.blank?

        keys = CachedSerializer.object_cache_keys(serializer, @include_tree)

        return {} if keys.blank?

        ActiveModelSerializers.config.cache_store.read_multi(*keys)
      end

      # Set @cached_attributes
      def cache_attributes
        return if @cached_attributes.present?

        @cached_attributes = cache_read_multi
      end

      # Get attributes from @cached_attributes
      # @return [Hash] cached attributes
      def cached_attributes(cached_serializer)
        return yield unless cached_serializer.cached?

        @cached_attributes.fetch(cached_serializer.cache_key) { yield }
      end

      def serializable_hash_for_single_resource(options)
        resource = resource_object_for(options)
        relationships = resource_relationships(options)
        resource.merge!(relationships)
      end

      def resource_relationships(options)
        relationships = {}
        serializer.associations(@include_tree).each do |association|
          relationships[association.key] = relationship_value_for(association, options)
        end

        relationships
      end

      def relationship_value_for(association, options)
        return association.options[:virtual_value] if association.options[:virtual_value]
        return unless association.serializer && association.serializer.object

        opts = instance_options.merge(include: @include_tree[association.key])
        Attributes.new(association.serializer, opts).serializable_hash(options)
      end

      # no-op: Attributes adapter does not include meta data, because it does not support root.
      def include_meta(json)
        json
      end

      def resource_object_for(options)
        cached_serializer = CachedSerializer.new(serializer)

        cached_attributes(cached_serializer) do
          cached_serializer.cache_check(self) do
            serializer.attributes(options[:fields])
          end
        end
      end
    end
  end
end
