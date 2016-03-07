module ActiveModelSerializers
  module Adapter
    class JsonApi < Base
      extend ActiveSupport::Autoload
      autoload :FragmentCache
      autoload :Jsonapi
      autoload :ResourceIdentifier
      autoload :Relationship
      autoload :Link
      autoload :PaginationLinks
      autoload :Meta
      autoload :Error
      autoload :Deserialization

      def initialize(serializer, options = {})
        super
        @include_tree = ActiveModel::Serializer::IncludeTree.from_include_args(options[:include])
        @fieldset = options[:fieldset] || ActiveModel::Serializer::Fieldset.new(options.delete(:fields))
      end

      # {http://jsonapi.org/format/#crud Requests are transactional, i.e. success or failure}
      # {http://jsonapi.org/format/#document-top-level data and errors MUST NOT coexist in the same document.}
      def serializable_hash(options = nil)
        options ||= {}
        if serializer.success?
          success_document(options)
        else
          failure_document
        end
      end

      # {http://jsonapi.org/format/#document-top-level Primary data}
      def success_document(options)
        is_collection = serializer.respond_to?(:each)
        serializers = is_collection ? serializer : [serializer]
        primary_data, included = resource_objects_for(serializers)

        hash = {}
        hash[:data] = is_collection ? primary_data : primary_data[0]
        hash[:included] = included if included.any?

        Jsonapi.add!(hash)

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

      # {http://jsonapi.org/format/#errors JSON API Errors}
      # TODO: look into caching
      # rubocop:disable Style/AsciiComments
      # definition:
      #   ☑ toplevel_errors array (required)
      #   ☐ toplevel_meta
      #   ☐ toplevel_jsonapi
      # rubocop:enable Style/AsciiComments
      def failure_document
        hash = {}
        # PR Please :)
        # Jsonapi.add!(hash)

        if serializer.respond_to?(:each)
          hash[:errors] = serializer.flat_map do |error_serializer|
            Error.resource_errors(error_serializer)
          end
        else
          hash[:errors] = Error.resource_errors(serializer)
        end
        hash
      end

      def fragment_cache(cached_hash, non_cached_hash)
        root = false if instance_options.include?(:include)
        FragmentCache.new.fragment_cache(root, cached_hash, non_cached_hash)
      end

      protected

      attr_reader :fieldset

      private

      # {http://jsonapi.org/format/#document-resource-objects Primary data}
      def resource_objects_for(serializers)
        @primary = []
        @included = []
        @resource_identifiers = Set.new
        serializers.each { |serializer| process_resource(serializer, true) }
        serializers.each { |serializer| process_relationships(serializer, @include_tree) }

        [@primary, @included]
      end

      def process_resource(serializer, primary)
        resource_identifier = ResourceIdentifier.new(serializer).as_json
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

      # {http://jsonapi.org/format/#document-resource-object-attributes Document Resource Object Attributes}
      def attributes_for(serializer, fields)
        serializer.attributes(fields).except(:id)
      end

      # {http://jsonapi.org/format/#document-resource-objects Document Resource Objects}
      def resource_object_for(serializer)
        resource_object = cache_check(serializer) do
          resource_object = ResourceIdentifier.new(serializer).as_json

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

      # {http://jsonapi.org/format/#document-resource-object-relationships Document Resource Object Relationship}
      def relationships_for(serializer, requested_associations)
        include_tree = ActiveModel::Serializer::IncludeTree.from_include_args(requested_associations)
        serializer.associations(include_tree).each_with_object({}) do |association, hash|
          hash[association.key] = Relationship.new(
            serializer,
            association.serializer,
            association.options,
            association.links,
            association.meta
          ).as_json
        end
      end

      # {http://jsonapi.org/format/#document-links Document Links}
      def links_for(serializer)
        serializer._links.each_with_object({}) do |(name, value), hash|
          hash[name] = Link.new(serializer, value).as_json
        end
      end

      # {http://jsonapi.org/format/#fetching-pagination Pagination Links}
      def pagination_links_for(serializer, options)
        PaginationLinks.new(serializer.object, options[:serialization_context]).serializable_hash(options)
      end

      # {http://jsonapi.org/format/#document-meta Docment Meta}
      def meta_for(serializer)
        Meta.new(serializer).as_json
      end
    end
  end
end
