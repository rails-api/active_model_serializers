require 'active_model/serializer/adapter/json_api/fragment_cache'
require 'active_model/serializer/adapter/json_api/pagination_links'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        def initialize(serializer, options = {})
          super
          @hash = { data: [] }

          @options[:include] ||= []
          if @options[:include].is_a?(String)
            @options[:include] = @options[:include].split(',')
          end

          fields = options.delete(:fields)
          if fields
            @fieldset = ActiveModel::Serializer::Fieldset.new(fields, serializer.json_key)
          else
            @fieldset = options[:fieldset]
          end
        end

        def serializable_hash(options = nil)
          options ||= {}
          if serializer.respond_to?(:each)
            serializer.each do |s|
              result = self.class.new(s, @options.merge(fieldset: @fieldset)).serializable_hash(options)
              @hash[:data] << result[:data]

              if result[:included]
                @hash[:included] ||= []
                @hash[:included] |= result[:included]
              end
            end

            add_links(options)
          else
            primary_data = primary_data_for(serializer, options)
            relationships = relationships_for(serializer)
            included = included_for(serializer)
            @hash[:data] = primary_data
            @hash[:data][:relationships] = relationships if relationships.any?
            @hash[:included] = included if included.any?
          end
          @hash
        end

        def fragment_cache(cached_hash, non_cached_hash)
          root = false if @options.include?(:include)
          JsonApi::FragmentCache.new.fragment_cache(root, cached_hash, non_cached_hash)
        end

        private

        def resource_identifier_type_for(serializer)
          if serializer.respond_to?(:type)
            serializer.type
          else
            type = serializer.object.class.model_name.singular
            ActiveModel::Serializer.config.jsonapi_type_transformer.call(type)
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
          options[:fields] = @fieldset && @fieldset.fields_for(serializer)

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
          Hash[serializer.associations.map { |association| [association.key, { data: relationship_value_for(association.serializer, association.options) }] }]
        end

        def included_for(serializer)
          serializer.associations.flat_map { |assoc| _included_for(assoc.key, assoc.serializer) }.uniq
        end

        def _included_for(resource_name, serializer, parent = nil)
          if serializer.respond_to?(:each)
            serializer.flat_map { |s| _included_for(resource_name, s, parent) }.uniq
          else
            return [] unless serializer && serializer.object
            result = []
            resource_path = [parent, resource_name].compact.join('.')

            if include_assoc?(resource_path)
              primary_data = primary_data_for(serializer, @options)
              relationships = relationships_for(serializer)
              primary_data[:relationships] = relationships if relationships.any?
              result.push(primary_data)
            end

            if include_nested_assoc?(resource_path)
              non_empty_associations = serializer.associations.select(&:serializer)

              non_empty_associations.each do |association|
                result.concat(_included_for(association.key, association.serializer, resource_path))
                result.uniq!
              end
            end
            result
          end
        end

        def include_assoc?(assoc)
          check_assoc("#{assoc}$")
        end

        def include_nested_assoc?(assoc)
          check_assoc("#{assoc}.")
        end

        def check_assoc(assoc)
          @options[:include].any? { |s| s.match(/^#{assoc.gsub('.', '\.')}/) }
        end

        def add_links(options)
          links = @hash.fetch(:links) { {} }
          collection = serializer.object
          @hash[:links] = add_pagination_links(links, collection, options) if paginated?(collection)
        end

        def add_pagination_links(links, collection, options)
          pagination_links = JsonApi::PaginationLinks.new(collection, options[:context]).serializable_hash(options)
          links.update(pagination_links)
        end

        def paginated?(collection)
          collection.respond_to?(:current_page) &&
            collection.respond_to?(:total_pages) &&
            collection.respond_to?(:size)
        end
      end
    end
  end
end
