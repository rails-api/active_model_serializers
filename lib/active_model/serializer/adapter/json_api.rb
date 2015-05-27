require 'active_model/serializer/adapter/json_api/fragment_cache'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        def initialize(serializer, options = {})
          super
          serializer.root = true
          @hash = { data: [] }

          if fields = options.delete(:fields)
            @fieldset = ActiveModel::Serializer::Fieldset.new(fields, serializer.json_key)
          else
            @fieldset = options[:fieldset]
          end
        end

        def serializable_hash(options = {})
          if serializer.respond_to?(:each)
            serializer.each do |s|
              result = self.class.new(s, @options.merge(fieldset: @fieldset)).serializable_hash
              @hash[:data] << result[:data]

              if result[:included]
                @hash[:included] ||= []
                @hash[:included] |= result[:included]
              end
            end
          else
            @hash[:data] = attributes_for_serializer(serializer, @options)
            add_resource_relationships(@hash[:data], serializer)
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
          resource[:relationships][name][:data] += serializers.map { |serializer| { type: serializer.type, id: serializer.id.to_s } }
        end

        def add_relationship(resource, name, serializer, val=nil)
          resource[:relationships] ||= {}
          resource[:relationships][name] = { data: nil }

          if serializer && serializer.object
            resource[:relationships][name][:data] = { type: serializer.type, id: serializer.id.to_s }
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
            serializer.each_association do |name, association, opts|
              add_included(name, association, resource_path) if association
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
          options[:required_fields] = [:id, :type]

          cache_check(serializer) do
            attributes = serializer.attributes(options)

            result = {
              id: attributes.delete(:id).to_s,
              type: attributes.delete(:type)
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

          serializer.each_association do |name, association, opts|
            attrs[:relationships] ||= {}

            if association.respond_to?(:each)
              add_relationships(attrs, name, association)
            else
              if opts[:virtual_value]
                add_relationship(attrs, name, nil, opts[:virtual_value])
              else
                add_relationship(attrs, name, association)
              end
            end

            if options[:add_included]
              Array(association).each do |association|
                add_included(name, association)
              end
            end
          end
        end
      end
    end
  end
end
