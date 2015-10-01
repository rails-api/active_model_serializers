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
            @fieldset = ActiveModel::Serializer::Fieldset.new(fields, serializer.json_key)
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
              serializable_hash_for_single_resource(options)
            end

          ApiObjects::JsonApi.add!(hash)

          hash
        end

        def fragment_cache(cached_hash, non_cached_hash)
          root = false if instance_options.include?(:include)
          ActiveModel::Serializer::Adapter::JsonApi::FragmentCache.new.fragment_cache(root, cached_hash, non_cached_hash)
        end

        private

        ActiveModel.silence_warnings do
          attr_reader :fieldset
        end

        def serializable_hash_for_collection(options)
          hash = { data: [] }
          serializer.each do |s|
            result = self.class.new(s, instance_options.merge(fieldset: fieldset)).serializable_hash(options)
            hash[:data] << result[:data]

            if result[:included]
              hash[:included] ||= []
              hash[:included] |= result[:included]
            end
          end

          if serializer.paginated?
            hash[:links] ||= {}
            hash[:links].update(links_for(serializer, options))
          end

          hash
        end

        def serializable_hash_for_single_resource(options)
          primary_data = primary_data_for(serializer, options)
          relationships = relationships_for(serializer)
          included = included_resources(@include_tree)
          hash = { data: primary_data }
          hash[:data][:relationships] = relationships if relationships.any?
          hash[:included] = included if included.any?

          hash
        end

        def resource_identifier_type_for(serializer)
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

        def resource_object_for(serializer, options = {})
          options[:fields] = fieldset && fieldset.fields_for(serializer)

          cache_check(serializer) do
            result = resource_identifier_for(serializer)
            attributes = serializer.attributes(options).except(:id)
            result[:attributes] = attributes if attributes.any?
            result
          end
        end

        def primary_data_for(serializer, options)
          if serializer.respond_to?(:each)
            serializer.map { |s| resource_object_for(s, options) }
          else
            resource_object_for(serializer, options)
          end
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
          serializer.associations.each_with_object({}) do |association, hash|
            hash[association.key] = { data: relationship_value_for(association.serializer, association.options) }
          end
        end

        def included_resources(include_tree)
          included = []

          serializer.associations(include_tree).each do |association|
            add_included_resources_for(association.serializer, include_tree[association.key], included)
          end

          included
        end

        def add_included_resources_for(serializer, include_tree, included)
          if serializer.respond_to?(:each)
            serializer.each { |s| add_included_resources_for(s, include_tree, included) }
          else
            return unless serializer && serializer.object

            primary_data = primary_data_for(serializer, instance_options)
            relationships = relationships_for(serializer)
            primary_data[:relationships] = relationships if relationships.any?

            return if included.include?(primary_data)
            included.push(primary_data)

            serializer.associations(include_tree).each do |association|
              add_included_resources_for(association.serializer, include_tree[association.key], included)
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
