module ActiveModel
  class Serializer
    module Adapter
      class JsonApi < Base
        extend ActiveSupport::Autoload
        autoload :PaginationLinks
        autoload :FragmentCache
        autoload :Link
        autoload :Association
        autoload :ResourceIdentifier
        autoload :Meta
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

          is_collection = serializer.respond_to?(:each)
          serializers = is_collection ? serializer : [serializer]
          primary_data, included = resource_objects_for(serializers)

          hash = {}
          hash[:data] = is_collection ? primary_data : primary_data[0]
          hash[:included] = included if included.any?

          ApiObjects::JsonApi.add!(hash)

          if instance_options[:links]
            hash[:links] ||= {}
            hash[:links].update(instance_options[:links])
          end

          if is_collection && serializer.paginated?
            hash[:links] ||= {}
            hash[:links].update(pagination_links_for(serializer, options))
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

        def resource_objects_for(serializers)
          @primary = []
          @included = []
          @resource_identifiers = Set.new
          serializers.each { |serializer| process_resource(serializer, true) }
          serializers.each { |serializer| process_relationships(serializer, @include_tree) }

          [@primary, @included]
        end

        def process_resource(serializer, primary)
          resource_identifier = JsonApi::ResourceIdentifier.new(serializer).as_json
          return false unless @resource_identifiers.add?(resource_identifier)

          resource_object = resource_object_for(serializer)
          if primary
            @primary << resource_object
          else
            @included << resource_object
          end

          true
        end

        def process_relationships(serializer, include_tree)
          serializer.associations(include_tree).each do |association|
            process_relationship(association.serializer, include_tree[association.key])
          end
        end

        def process_relationship(serializer, include_tree)
          if serializer.respond_to?(:each)
            serializer.each { |s| process_relationship(s, include_tree) }
            return
          end
          return unless serializer && serializer.object
          return unless process_resource(serializer, false)

          process_relationships(serializer, include_tree)
        end

        def attributes_for(serializer, fields)
          serializer.attributes(fields).except(:id)
        end

        def resource_object_for(serializer)
          resource_object = cache_check(serializer) do
            resource_object = JsonApi::ResourceIdentifier.new(serializer).as_json

            requested_fields = fieldset && fieldset.fields_for(resource_object[:type])
            attributes = attributes_for(serializer, requested_fields)
            resource_object[:attributes] = attributes if attributes.any?
            resource_object
          end

          requested_associations = fieldset.fields_for(resource_object[:type]) || '*'
          relationships = relationships_for(serializer, requested_associations)
          resource_object[:relationships] = relationships if relationships.any?

          links = links_for(serializer)
          resource_object[:links] = links if links.any?

          meta = meta_for(serializer)
          resource_object[:meta] = meta unless meta.nil?

          resource_object
        end

        def relationships_for(serializer, requested_associations)
          include_tree = IncludeTree.from_include_args(requested_associations)
          serializer.associations(include_tree).each_with_object({}) do |association, hash|
            hash[association.key] = JsonApi::Association.new(serializer,
              association.serializer,
              association.options,
              association.links,
              association.meta)
                                    .as_json
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

        def meta_for(serializer)
          Meta.new(serializer).as_json
        end
      end
    end
  end
end
