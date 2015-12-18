module ActiveModel
  class Serializer
    module Adapter
      class JsonApi < Base
        extend ActiveSupport::Autoload
        autoload :PaginationLinks
        autoload :FragmentCache
        autoload :ApiObjects

        def initialize(serializer, options = {})
          super
          @include_tree = IncludeTree.from_include_args(options[:include])
          @fieldset = options[:fieldset] || ActiveModel::Serializer::Fieldset.new(options[:fields])
        end

        # Build JSON API document.
        # @return [Hash] document
        def serializable_hash(options = nil)
          options ||= {}

          primary_data, included = resource_objects_for(serializer)

          is_collection = serializer.respond_to?(:each)
          hash = {}

          # Unpack data from `primary_data` array when serializing a single resource.
          hash[:data] = is_collection ? primary_data.map(&:to_h) : primary_data.first.to_h

          hash[:included] = included.map(&:to_h) if included.any?

          ApiObjects::JsonApiObject.add!(hash)

          if is_collection && serializer.paginated?
            hash[:links] ||= {}
            hash[:links].update(pagination_links_for(serializer, options))
          end

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

        private

        # Build the requested resource objects.
        # @return [Array] [primary, included] Pair of arrays containing primary and included
        #   resources objects respectively.
        #
        # @api private
        def resource_objects_for(serializer)
          resources = _resource_objects_for(serializer, @include_tree, true).values
          resources.each_with_object([[], []]) do |resource, (primary, included)|
            if resource[:is_primary]
              primary.push(resource[:resource_object])
            else
              included.push(resource[:resource_object])
            end
          end
        end

        # Recursively build all requested resource objects and flag them as primary when applicable.
        # @return [Hash<ResourceIdentifier, Hash>]
        #   Hash of hashes each describing a resource object and whether it is primary or included.
        #
        # @api private
        def _resource_objects_for(serializer, include_tree, is_primary, hashes = {})
          if serializer.respond_to?(:each)
            serializer.each { |s| _resource_objects_for(s, include_tree, is_primary, hashes) }
            return hashes
          end

          return hashes unless serializer && serializer.object

          resource_identifier = ApiObjects::ResourceIdentifier.from_serializer(serializer)
          if hashes[resource_identifier]
            hashes[resource_identifier][:is_primary] ||= is_primary
            return hashes
          end

          resource_object = ApiObjects::Resource.new(
            resource_identifier,
            attributes_for(serializer),
            relationships_for(serializer),
            links_for(serializer))
          hashes[resource_identifier] = { resource_object: resource_object, is_primary: is_primary }

          serializer.associations(include_tree).each do |association|
            _resource_objects_for(association.serializer, include_tree[association.key], false, hashes)
          end

          hashes
        end

        # Get resource attributes.
        # @return [Hash] attributes
        #
        # @api private
        def attributes_for(serializer)
          hash = cache_check(serializer) do
            resource_type = ApiObjects::ResourceIdentifier.type_for(serializer)
            requested_fields = @fieldset.fields_for(resource_type)
            attributes = serializer.attributes(requested_fields).except(:id)

            # NOTE(beauby): Wrapping attributes inside a hash is currently
            #   needed for caching.
            { attributes: attributes }
          end

          hash[:attributes]
        end

        # Get resource linkage for an association.
        # @return [Hash] linkage
        #
        # @api private
        def linkage_for(serializer, options = {})
          if serializer.respond_to?(:each)
            serializer.map { |s| ApiObjects::ResourceIdentifier.from_serializer(s) }
          else
            if options[:virtual_value]
              options[:virtual_value]
            elsif serializer && serializer.object
              ApiObjects::ResourceIdentifier.from_serializer(serializer)
            end
          end
        end

        # Get resource relationships.
        # @return [Hash<String, Relationship>] relationships
        #
        # @api private
        def relationships_for(serializer)
          resource_type = ApiObjects::ResourceIdentifier.type_for(serializer)
          requested_associations = @fieldset.fields_for(resource_type) || '*'
          include_tree = IncludeTree.from_include_args(requested_associations)
          serializer.associations(include_tree).each_with_object({}) do |association, hash|
            hash[association.key] = ApiObjects::Relationship.new(data: linkage_for(association.serializer, association.options))
          end
        end

        # Get resource links.
        #
        # @api private
        def links_for(serializer)
          serializer.links.each_with_object({}) do |(name, value), hash|
            hash[name] =
              if value.respond_to?(:call)
                link = ApiObjects::Link.new(serializer)
                link.instance_eval(&value)

                link.to_hash
              else
                value
              end
          end
        end

        # Get pagination links.
        #
        # @api private
        def pagination_links_for(serializer, options)
          PaginationLinks.new(serializer.object, options[:serialization_context]).serializable_hash(options)
        end
      end
    end
  end
end
