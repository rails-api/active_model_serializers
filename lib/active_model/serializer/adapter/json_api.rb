module ActiveModel
  class Serializer
    module Adapter
      class JsonApi < Base
        extend ActiveSupport::Autoload
        autoload :PaginationLinks
        autoload :FragmentCache

        # TODO: if we like this abstraction and other API objects to it,
        # then extract to its own file and require it.
        module ApiObjects
          module JsonApi
            ActiveModel::Serializer.config.jsonapi_version = '1.0'
            ActiveModel::Serializer.config.jsonapi_toplevel_meta = {}
            # Make JSON API top-level jsonapi member opt-in
            # ref: http://jsonapi.org/format/#document-top-level
            ActiveModel::Serializer.config.jsonapi_include_toplevel_object = false

            module_function

            def add!(hash)
              hash.merge!(object) if include_object?
            end

            def include_object?
              ActiveModel::Serializer.config.jsonapi_include_toplevel_object
            end

            # TODO: see if we can cache this
            def object
              object = {
                jsonapi: {
                  version: ActiveModel::Serializer.config.jsonapi_version,
                  meta: ActiveModel::Serializer.config.jsonapi_toplevel_meta
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

          fields = options.delete(:fields)
          if fields
            @fieldset = ActiveModel::Serializer::Fieldset.new(fields)
          else
            @fieldset = options[:fieldset]
          end
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
            hash[:links].update(links_for(serializer, options))
          end

          hash
        end

        def serializable_hash_for_single_resource
          primary_data = primary_data_for(serializer)
          relationships = relationships_for(serializer)
          primary_data[:relationships] = relationships if relationships.any?
          hash = { data: primary_data }

          included = included_resources(@include_tree, [primary_data])
          hash[:included] = included if included.any?

          hash
        end

        def resource_identifier_type_for(serializer)
          return serializer._type if serializer._type
          if ActiveModel::Serializer.config.jsonapi_resource_type == :singular
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

        def resource_object_for(serializer)
          cache_check(serializer) do
            resource_object = resource_identifier_for(serializer)
            requested_fields = fieldset && fieldset.fields_for(resource_object[:type])
            attributes = serializer.attributes.except(:id)
            attributes.slice!(*requested_fields) if requested_fields
            resource_object[:attributes] = attributes if attributes.any?
            resource_object
          end
        end

        def primary_data_for(serializer)
          if serializer.respond_to?(:each)
            serializer.map { |s| resource_object_for(s) }
          else
            resource_object_for(serializer)
          end
        end

        def relationship_data_for(serializer, options = {})
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

        def relationship_links_for(name, owner, options = {})
          options[:links].each_with_object({}) do |(key, link), hash|
            if link.respond_to?(:call)
              hash[key] = link.call(owner, name)
            else
              hash[key] = link
            end

            hash
          end
        end

        def relationship_meta_for(name, owner, options = {})
          if options[:meta].respond_to?(:call)
            options[:meta].call(owner, name)
          else
            options[:meta]
          end
        end

        def relationships_for(serializer)
          serializer.associations.each_with_object({}) do |association, hash|
            hash[association.key] = {}

            if association.data?
              hash[association.key][:data] = relationship_data_for(association.serializer, association.options)
            end

            if association.options.fetch(:links, false)
              hash[association.key][:links] = relationship_links_for(association.name, serializer.object, association.options)
            end

            if association.options.fetch(:meta, false)
              hash[association.key][:meta] = relationship_meta_for(association.name, serializer.object, association.options)
            end
          end
        end

        def included_resources(include_tree, primary_data)
          included = []

          serializer.associations(include_tree)
            .select(&:data?)
            .each do |association|
              add_included_resources_for(association.serializer, include_tree[association.key], primary_data, included)
            end

          included
        end

        def add_included_resources_for(serializer, include_tree, primary_data, included)
          if serializer.respond_to?(:each)
            serializer.each { |s| add_included_resources_for(s, include_tree, primary_data, included) }
          else
            return unless serializer && serializer.object

            resource_object = primary_data_for(serializer)
            relationships = relationships_for(serializer)
            resource_object[:relationships] = relationships if relationships.any?

            return if included.include?(resource_object) || primary_data.include?(resource_object)
            included.push(resource_object)

            serializer.associations(include_tree)
              .select(&:data?)
              .each do |association|
                add_included_resources_for(association.serializer, include_tree[association.key], primary_data, included)
              end
          end
        end

        def links_for(serializer, options)
          JsonApi::PaginationLinks.new(serializer.object, options[:context]).serializable_hash(options)
        end
      end
    end
  end
end
