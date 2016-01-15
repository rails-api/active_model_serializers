module ActiveModel
  class Serializer
    module Adapter
      class JsonApi < Base
        extend ActiveSupport::Autoload
        autoload :PaginationLinks
        autoload :FragmentCache
        autoload :Link
        autoload :Deserialization

        # TODO: if we like this abstraction and other API objects to it,
        # then extract to its own file and require it.
        module ApiObjects
          module JsonApi
            ActiveModelSerializers.config.jsonapi_version = '1.0'
            ActiveModelSerializers.config.jsonapi_toplevel_meta = {}
            # Make JSON API top-level jsonapi member opt-in
            # ref: http://jsonapi.org/format/#document-top-level
            ActiveModelSerializers.config.jsonapi_include_toplevel_object = false

            module_function

            def add!(hash)
              hash.merge!(object) if include_object?
            end

            def include_object?
              ActiveModelSerializers.config.jsonapi_include_toplevel_object
            end

            # TODO: see if we can cache this
            def object
              object = {
                jsonapi: {
                  version: ActiveModelSerializers.config.jsonapi_version,
                  meta: ActiveModelSerializers.config.jsonapi_toplevel_meta
                }
              }
              object[:jsonapi].reject! { |_, v| v.blank? }

              object
            end
          end
        end

        def initialize(serializer, options = {})
          super
          @include_tree = IncludeTree.from_include_args(options[:include])
          @fieldset = options[:fieldset] || ActiveModel::Serializer::Fieldset.new(options.delete(:fields))
        end

        def serializable_hash(options = nil)
          options ||= {}

          hash =
            if serializer.respond_to?(:each)
              serializable_hash_for_collection(options)
            else
              serializable_hash_for_single_resource
            end

          ApiObjects::JsonApi.add!(hash)

          if instance_options[:links]
            hash[:links] ||= {}
            hash[:links].update(instance_options[:links])
          end

          hash
        end

        def fragment_cache(cached_hash, non_cached_hash)
          root = false if instance_options.include?(:include)
          ActiveModel::Serializer::Adapter::JsonApi::FragmentCache.new.fragment_cache(root, cached_hash, non_cached_hash)
        end

        protected

        attr_reader :fieldset

        private

        def serializable_hash_for_collection(options)
          hash = { data: [] }
          included = []
          serializer.each do |s|
            result = self.class.new(s, instance_options.merge(fieldset: fieldset)).serializable_hash(options)
            hash[:data] << result[:data]
            next unless result[:included]

            included |= result[:included]
          end

          included.delete_if { |resource| hash[:data].include?(resource) }
          hash[:included] = included if included.any?

          if serializer.paginated?
            hash[:links] ||= {}
            hash[:links].update(pagination_links_for(serializer, options))
          end

          hash
        end

        def serializable_hash_for_single_resource
          primary_data = resource_object_for(serializer)

          hash = { data: primary_data }

          included = included_resources(@include_tree, [primary_data])
          hash[:included] = included if included.any?

          hash
        end

        def resource_identifier_type_for(serializer)
          return serializer._type if serializer._type
          if ActiveModelSerializers.config.jsonapi_resource_type == :singular
            serializer.object.class.model_name.singular
          else
            serializer.object.class.model_name.plural
          end
        end

        def resource_identifier_id_for(serializer)
          if serializer.respond_to?(:id)
            serializer.id
          else
            serializer.object.id
          end
        end

        def resource_identifier_for(serializer)
          type = resource_identifier_type_for(serializer)
          id   = resource_identifier_id_for(serializer)

          { id: id.to_s, type: type }
        end

        def attributes_for(serializer, fields)
          serializer.attributes(fields).except(:id)
        end

        def resource_object_for(serializer)
          resource_object = cache_check(serializer) do
            resource_object = resource_identifier_for(serializer)

            requested_fields = fieldset && fieldset.fields_for(resource_object[:type])
            attributes = attributes_for(serializer, requested_fields)
            resource_object[:attributes] = attributes if attributes.any?
            resource_object
          end

          relationships = relationships_for(serializer)
          resource_object[:relationships] = relationships if relationships.any?

          links = links_for(serializer)
          resource_object[:links] = links if links.any?

          resource_object
        end

        def relationship_value_for(serializer, options = {})
          if serializer.respond_to?(:each)
            serializer.map { |s| resource_identifier_for(s) }
          else
            if options[:virtual_value]
              options[:virtual_value]
            elsif serializer && serializer.object
              resource_identifier_for(serializer)
            end
          end
        end

        def relationships_for(serializer)
          resource_type = resource_identifier_type_for(serializer)
          requested_associations = fieldset.fields_for(resource_type) || '*'
          include_tree = IncludeTree.from_include_args(requested_associations)
          serializer.associations(include_tree).each_with_object({}) do |association, hash|
            hash[association.key] = { data: relationship_value_for(association.serializer, association.options) }
          end
        end

        def included_resources(include_tree, primary_data)
          included = []

          serializer.associations(include_tree).each do |association|
            add_included_resources_for(association.serializer, include_tree[association.key], primary_data, included)
          end

          included
        end

        def add_included_resources_for(serializer, include_tree, primary_data, included)
          if serializer.respond_to?(:each)
            serializer.each { |s| add_included_resources_for(s, include_tree, primary_data, included) }
          else
            return unless serializer && serializer.object

            resource_object = resource_object_for(serializer)

            return if included.include?(resource_object) || primary_data.include?(resource_object)
            included.push(resource_object)

            serializer.associations(include_tree).each do |association|
              add_included_resources_for(association.serializer, include_tree[association.key], primary_data, included)
            end
          end
        end

        def links_for(serializer)
          serializer._links.each_with_object({}) do |(name, value), hash|
            hash[name] = Link.new(serializer, value).as_json
          end
        end

        def pagination_links_for(serializer, options)
          JsonApi::PaginationLinks.new(serializer.object, options[:serialization_context]).serializable_hash(options)
        end
      end
    end
  end
end
