class ActiveModel::Serializer::Adapter::JsonApi < ActiveModel::Serializer::Adapter
        extend ActiveSupport::Autoload
        autoload :PaginationLinks
        autoload :FragmentCache

        def initialize(serializer, options = {})
          super
          @hash = { data: [] }

          @included = ActiveModel::Serializer::Utils.include_args_to_hash(@options[:include])
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
          ActiveModel::Serializer::Adapter::JsonApi::FragmentCache.new.fragment_cache(root, cached_hash, non_cached_hash)
        end

        private

        def formatted_type(type)
          type = if ActiveModel::Serializer.config.jsonapi_resource_type == :singular
                   type.singularize
                 else
                   type.pluralize
                 end
          type.underscore
        end

        def resource_identifier_type_for_association(serializer, association)
          if association.serializer.respond_to?(:type)
            formatted_type(association.serializer.type)
          elsif serializer.object.class.respond_to?(:reflections)
            reflection = serializer.object.class.reflections[association.key.to_s]
            formatted_type(reflection.class_name)
          else
            resource_identifier_type_for(association.serializer)
          end
        end

        def resource_identifier_type_for(serializer, association = nil)
          if association
            resource_identifier_type_for_association(serializer, association)
          else
            if serializer.respond_to?(:type)
              serializer.type
            elsif serializer && serializer.object
              if serializer.object.class.respond_to?(:model_name)
                formatted_type(serializer.object.class.model_name.singular)
              else
                formatted_type(serializer.object.class_name)
              end
            end
          end
        end

        def resource_identifier_id_for(serializer, association = nil)
          if association
            if serializer.respond_to?("#{association.key}_id")
              serializer.send("#{association.key}_id")
            else
              resource_identifier_id_for(association.serializer)
            end
          elsif serializer.respond_to?(:id)
            serializer.id
          elsif serializer && serializer.object
            serializer.object.id
          end
        end

        def resource_identifier_for(serializer, association = nil)
          type = resource_identifier_type_for(serializer, association)
          id   = resource_identifier_id_for(serializer, association)

          { id: id.to_s, type: type } unless id.nil?
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

        def relationship_value_for(serializer, association)
          if association.serializer.respond_to?(:each)
            association.serializer.map { |s| resource_identifier_for(s) }
          else
            if association.options[:virtual_value]
              association.options[:virtual_value]
            elsif serializer.class._reflections.find { |r| r.name == association.key }.is_a? BelongsToReflection
              resource_identifier_for(serializer, association)
            elsif association.serializer && association.serializer.object
              resource_identifier_for(association.serializer)
            end
          end
        end

        def relationships_for(serializer)
          Hash[serializer.associations.map { |association| [association.key, { data: relationship_value_for(serializer, association) }] }]
        end

        def included_for(serializer)
          included = @included.flat_map do |inc|
            association = serializer.associations.find { |assoc| assoc.key == inc.first }
            _included_for(association.serializer, inc.second) if association
          end

          included.uniq
        end

        def _included_for(serializer, includes)
          if serializer.respond_to?(:each)
            serializer.flat_map { |s| _included_for(s, includes) }.uniq
          else
            return [] unless serializer && serializer.object

            primary_data = primary_data_for(serializer, @options)
            relationships = relationships_for(serializer)
            primary_data[:relationships] = relationships if relationships.any?

            included = [primary_data]

            includes.each do |inc|
              association = serializer.associations.find { |assoc| assoc.key == inc.first }
              if association
                included.concat(_included_for(association.serializer, inc.second))
                included.uniq!
              end
            end

            included
          end
        end

        def add_links(options)
          links = @hash.fetch(:links) { {} }
          collection = serializer.object
          @hash[:links] = add_pagination_links(links, collection, options) if paginated?(collection)
        end

        def add_pagination_links(links, resources, options)
          pagination_links = ActiveModel::Serializer::Adapter::JsonApi::PaginationLinks.new(resources, options[:context]).serializable_hash(options)
          links.update(pagination_links)
        end

        def paginated?(collection)
          collection.respond_to?(:current_page) &&
            collection.respond_to?(:total_pages) &&
            collection.respond_to?(:size)
        end
end
