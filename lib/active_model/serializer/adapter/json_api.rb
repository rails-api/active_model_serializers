require 'active_model/serializer/adapter/json_api/fragment_cache'
require 'active_model/serializer/adapter/json_api/pagination_links'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        @root = :data
        DEFAULT_ATTRIBUTES = [:type, :id]

        def self.params(permitted, associations)
          relationships = {}
          associations.each do |assoc|
             relationships[assoc] = {}
             relationships[assoc][@root] = DEFAULT_ATTRIBUTES
           end

          return :type, {attributes: permitted}, {relationships: relationships}
        end

        def self.parse(params)
          attrs, assoc = {}, {}
          attrs = params['attributes'] if params['attributes']
          assoc = params['relationships'].map {|a| {a.shift => a.first['data']['type'].camelize.singularize.safe_constantize.find(a.shift['data']['id'])}} if params['relationships']
          assoc.reduce attrs, :merge
        end

        def initialize(serializer, options = {})
          super
          @root = self.class.root
          @hash = {}
          @hash[@root] = []

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
              @hash[@root] << result[@root]

              if result[:included]
                @hash[:included] ||= []
                @hash[:included] |= result[:included]
              end
            end

            add_links(options)
          else
            @hash[@root] = attributes_for_serializer(serializer, options)
            add_resource_relationships(@hash[@root], serializer)
          end
          @hash
        end

        def fragment_cache(cached_hash, non_cached_hash)
          root = false if @options.include?(:include)
          JsonApi::FragmentCache.new().fragment_cache(root, cached_hash, non_cached_hash)
        end

        private

        def add_relationships(resource, name, serializers)
          resource[:relationships] ||= {}
          resource[:relationships][name] ||= { data: [] }
          resource[:relationships][name][@root] ||= []
          resource[:relationships][name][@root] += serializers.map { |serializer| { type: serializer.json_api_type, id: serializer.id.to_s } }
        end

        def add_relationship(resource, name, serializer, val=nil)
          resource[:relationships] ||= {}
          resource[:relationships][name] = {}
          resource[:relationships][name][@root] = val

          if serializer && serializer.object
            resource[:relationships][name][@root] = { type: serializer.json_api_type, id: serializer.id.to_s }
          end
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
            result = []
            serializer.each do |object|
              result << resource_object_for(object, options)
            end
          else
            result = resource_object_for(serializer, options)
          end
          result
        end

        def resource_object_for(serializer, options)
          options[:fields] = @fieldset && @fieldset.fields_for(serializer)
          options[:required_fields] = [:id, :json_api_type]

          cache_check(serializer) do
            attributes = serializer.attributes(options)

            result = {
              id: attributes.delete(:id).to_s,
              type: attributes.delete(:json_api_type)
            }

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

        def add_resource_relationships(attrs, serializer, options = {})
          options[:add_included] = options.fetch(:add_included, true)

          serializer.associations.each do |association|
            key = association.key
            serializer = association.serializer
            opts = association.options

            attrs[:relationships] ||= {}

            if serializer.respond_to?(:each)
              add_relationships(attrs, key, serializer)
            else
              if opts[:virtual_value]
                add_relationship(attrs, key, nil, opts[:virtual_value])
              else
                add_relationship(attrs, key, serializer)
              end
            end

            if options[:add_included]
              Array(serializer).each do |s|
                add_included(key, s)
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
