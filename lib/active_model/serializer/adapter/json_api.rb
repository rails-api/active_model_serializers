require 'active_model/serializer/adapter/json_api/fragment_cache'
require 'active_model/serializer/adapter/json_api/pagination_links'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        def initialize(serializer, options = {})
          super
          @hash = { data: [] }

          if fields = options.delete(:fields)
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
            @hash[:data] = attributes_for_serializer(serializer, options)
            add_resource_relationships(@hash[:data], serializer)
          end
          @hash
        end

        def fragment_cache(cached_hash, non_cached_hash)
          root = false if @options.include?(:include)
          JsonApi::FragmentCache.new().fragment_cache(root, cached_hash, non_cached_hash)
        end

        private

        def resource_identifier_type(serializer)
          if ActiveModel::Serializer.config.jsonapi_resource_type == :singular
            serializer.object.class.model_name.singular
          else
            serializer.object.class.model_name.plural
          end
        end

        def resource_identifier_id(serializer)
          if serializer.respond_to?(:id)
            serializer.id.to_s
          else
            serializer.object.id.to_s
          end
        end

        def resource_identifier(serializer)
          type = resource_identifier_type(serializer)
          id   = resource_identifier_id(serializer)

          { id: id, type: type }
        end

        def add_included(resource_name, serializers, parent = nil)
          unless serializers.respond_to?(:each)
            return unless serializers.object
            serializers = Array(serializers)
          end
          resource_path = [parent, resource_name].compact.join('.')
          if include_assoc?(resource_path)
            @hash[:included] ||= []

            serializers.each do |serializer|
              attrs = attributes_for_serializer(serializer, @options)

              add_resource_relationships(attrs, serializer, add_included: false)

              @hash[:included].push(attrs) unless @hash[:included].include?(attrs)
            end
          end

          serializers.each do |serializer|
            serializer.associations.each do |association|
              serializer = association.serializer

              add_included(association.key, serializer, resource_path) if serializer
            end if include_nested_assoc? resource_path
          end
        end

        def attributes_for_serializer(serializer, options)
          if serializer.respond_to?(:each)
            serializer.map { |s| resource_object_for(s, options) }
          else
            resource_object_for(serializer, options)
          end
        end

        def resource_object_for(serializer, options)
          options[:fields] = @fieldset && @fieldset.fields_for(serializer)

          cache_check(serializer) do
            result = resource_identifier(serializer)
            attributes = serializer.attributes(options).except(:id)
            result[:attributes] = attributes if attributes.any?
            result
          end
        end

        def include_assoc?(assoc)
          return false unless @options[:include]
          check_assoc("#{assoc}$")
        end

        def include_nested_assoc?(assoc)
          return false unless @options[:include]
          check_assoc("#{assoc}.")
        end

        def check_assoc(assoc)
          include_opt = @options[:include]
          include_opt = include_opt.split(',') if include_opt.is_a?(String)
          include_opt.any? do |s|
            s.match(/^#{assoc.gsub('.', '\.')}/)
          end
        end

        def resource_relationship_value(serializer, options = {})
          if serializer.respond_to?(:each)
            serializer.map { |s| resource_identifier(s) }
          else
            if options[:virtual_value]
              options[:virtual_value]
            elsif serializer && serializer.object
              resource_identifier(serializer)
            else
              nil
            end
          end
        end

        def add_resource_relationships(attrs, serializer, options = {})
          options[:add_included] = options.fetch(:add_included, true)
          attrs[:relationships] = {} if serializer.associations.any?
          serializer.associations.each do |association|
            value = resource_relationship_value(association.serializer, association.options)
            attrs[:relationships][association.key] = { data: value }
            if options[:add_included]
              Array(association.serializer).each do |s|
                add_included(association.key, s)
              end
            end
          end
        end

        def add_links(options)
          links = @hash.fetch(:links) { {} }
          resources = serializer.instance_variable_get(:@resource)
          @hash[:links] = add_pagination_links(links, resources, options) if is_paginated?(resources)
        end

        def add_pagination_links(links, resources, options)
          pagination_links = JsonApi::PaginationLinks.new(resources, options[:context]).serializable_hash(options)
          links.update(pagination_links)
        end

        def is_paginated?(resource)
          resource.respond_to?(:current_page) &&
            resource.respond_to?(:total_pages) &&
            resource.respond_to?(:size)
        end
      end
    end
  end
end
