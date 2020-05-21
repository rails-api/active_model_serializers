module ActiveModelSerializers
  module Adapter
    class HypertextApplicationLanguage < Base
      extend ActiveSupport::Autoload
      autoload :Link
      autoload :PaginationLinks

      def initialize(serializer, options = {})
        super
        @include_directive = JSONAPI::IncludeDirective.new(options[:include], allow_wildcard: true)
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
        hash = {}
        hash[:_links] = { self: { href: instance_options.fetch(:serialization_context).request_url } }
        hash[:_links].update(pagination_links_for(serializer))
        hash[:_embedded] = {}
        hash[:_embedded][:items] =
          serializer.map do |s|
            HypertextApplicationLanguage.new(s, instance_options)
                                        .serializable_hash(options)
          end
      end

      def pagination_links_for(serializer)
        PaginationLinks.new(serializer.object, instance_options).as_json
      end

      def serializable_hash_for_single_resource(options)
        resource = resource_object_for(options)
        relationships = resource_relationships(options)
        links = link_relationships
        resource[:_links] = links if links.any?
        resource[:_embedded] = relationships if relationships.any?
      end

      def resource_relationships(options)
        associations = serializer.associations(@include_directive)
        associations.each_with_object({}) do |association, acc|
          acc[association.key] = relationship_value_for(association, options)
        end
      end

      def link_relationships
        serializer._links.each_with_object({}) do |(name, value), hash|
          hash[name] = Link.new(serializer, value).as_json
        end
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
