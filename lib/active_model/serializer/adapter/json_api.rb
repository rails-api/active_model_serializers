module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        def initialize(serializer, options = {})
          super
          serializer.root = true
          @hash = {}
          @top = @options.fetch(:top) { @hash }

          if fields = options.delete(:fields)
            @fieldset = ActiveModel::Serializer::Fieldset.new(fields, serializer.json_key)
          else
            @fieldset = options[:fieldset]
          end
        end

        def serializable_hash(options = {})
          @root = :data

          if serializer.respond_to?(:each)
            @hash[@root] = serializer.map do |s|
              self.class.new(s, @options.merge(top: @top, fieldset: @fieldset)).serializable_hash[@root]
            end
          else
            @hash = cached_object do
              @hash[@root] = attributes_for_serializer(serializer, @options)
              add_resource_links(@hash[@root], serializer)
              @hash
            end
          end
          @hash
        end

        private

        def add_links(resource, name, serializers)
          type = serialized_object_type(serializers)
          resource[:links] ||= {}

          if name.to_s == type || !type
            resource[:links][name] ||= []
            resource[:links][name] += serializers.map{|serializer| serializer.id.to_s }
          else
            resource[:links][name] ||= {}
            resource[:links][name][:type] = type
            resource[:links][name][:ids] ||= []
            resource[:links][name][:ids] += serializers.map{|serializer| serializer.id.to_s }
          end
        end

        def add_link(resource, name, serializer)
          resource[:links] ||= {}
          resource[:links][name] = nil

          if serializer && serializer.object
            type = serialized_object_type(serializer)
            if name.to_s == type || !type
              resource[:links][name] = serializer.id.to_s
            else
              resource[:links][name] ||= {}
              resource[:links][name][:type] = type
              resource[:links][name][:id] = serializer.id.to_s
            end
          end
        end

        def add_linked(resource_name, serializers, parent = nil)
          serializers = Array(serializers) unless serializers.respond_to?(:each)

          resource_path = [parent, resource_name].compact.join('.')

          if include_assoc?(resource_path) && resource_type = serialized_object_type(serializers)
            plural_name = resource_type.pluralize.to_sym
            @top[:linked] ||= {}
            @top[:linked][plural_name] ||= []

            serializers.each do |serializer|
              attrs = attributes_for_serializer(serializer, @options)

              add_resource_links(attrs, serializer, add_linked: false)

              @top[:linked][plural_name].push(attrs) unless @top[:linked][plural_name].include?(attrs)
            end
          end

          serializers.each do |serializer|
            serializer.each_association do |name, association, opts|
              add_linked(name, association, resource_path) if association
            end if include_nested_assoc? resource_path
          end
        end


        def attributes_for_serializer(serializer, options)
          if serializer.respond_to?(:each)
            result = []
            serializer.each do |object|
              options[:fields] = @fieldset && @fieldset.fields_for(serializer)
              attributes = object.attributes(options)
              attributes[:id] = attributes[:id].to_s if attributes[:id]
              result << attributes
            end
          else
            options[:fields] = @fieldset && @fieldset.fields_for(serializer)
            result = serializer.attributes(options)
            result[:id] = result[:id].to_s if result[:id]
          end

          result
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

        def serialized_object_type(serializer)
          return false unless Array(serializer).first
          type_name = Array(serializer).first.object.class.to_s.demodulize.underscore
          if serializer.respond_to?(:first)
            type_name.pluralize
          else
            type_name
          end
        end

        def add_resource_links(attrs, serializer, options = {})
          options[:add_linked] = options.fetch(:add_linked, true)

          serializer.each_association do |name, association, opts|
            attrs[:links] ||= {}

            if association.respond_to?(:each)
              add_links(attrs, name, association)
            else
              add_link(attrs, name, association)
            end

            if @options[:embed] != :ids && options[:add_linked]
              Array(association).each do |association|
                add_linked(name, association)
              end
            end
          end
        end
      end
    end
  end
end
