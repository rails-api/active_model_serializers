module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        def initialize(serializer, options = {})
          super
          serializer.root = true
          @hash = {}
          @top = @options.fetch(:top) { @hash }
        end

        def serializable_hash(options = {})
          @root = (@options[:root] || serializer.json_key.to_s.pluralize).to_sym

          if serializer.respond_to?(:each)
            @hash[@root] = serializer.map do |s|
              self.class.new(s, @options.merge(top: @top)).serializable_hash[@root]
            end
          else
            @hash[@root] = attributes_for_serializer(serializer, @options)

            add_resource_links(@hash[@root], serializer)
          end

          @hash
        end

        private

        def add_links(resource, name, serializers, opts = {})
          type = serialized_object_type(serializers)
          href = serialized_object_href(serializers)  
          resource[:links] ||= {}

          if opts[:skip_type_check] || ((name.to_s == type || !type) && !href )
            resource[:links][name] ||= []
            resource[:links][name] += serializers.map{|serializer| serializer.identifier }
          else
            resource[:links][name] ||= {}
            resource[:links][name][:href] = href if href
            resource[:links][name][:type] = type
            resource[:links][name][:ids] ||= []
            resource[:links][name][:ids] += serializers.map{|serializer| serializer.identifier }
          end
        end

        def add_link(resource, name, serializer, opts = {})
          resource[:links] ||= {}
          resource[:links][name] = nil

          if serializer
            type = serialized_object_type(serializer)
            if opts[:skip_type_check] || name.to_s == type || !type
              resource[:links][name] = serializer.identifier
            else
              resource[:links][name] ||= {}
              resource[:links][name][:type] = type
              resource[:links][name][:id] = serializer.identifier
            end
          end
        end

        def add_linked(resource_name, serializers, parent = nil, opts = {})
          serializers = Array(serializers) unless serializers.respond_to?(:each)

          resource_path = [parent, resource_name].compact.join('.')

          if include_assoc?(resource_path)
            plural_name = serialized_object_type(serializers).pluralize.to_sym
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
              add_linked(name, association, resource_path, opts) if association
            end if include_nested_assoc? resource_path
          end
        end

        def attributes_for_serializer(serializer, options)
          if serializer.respond_to?(:each)
            result = []
            serializer.each do |object|
              attributes = object.attributes(options)
              attributes[:id] = attributes[:id].to_s if attributes[:id]
              result << attributes
            end
          else
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
          @options[:include].split(',').any? do |s|
            s.match(/^#{assoc.gsub('.', '\.')}/)
          end
        end

        def serialized_object_href(serializer)
          return false unless Array(serializer).first                 
          Array(serializer).first.object.href 
        end

        def serialized_object_type(serializer)
          return false unless Array(serializer).first
          klass = Array(serializer).first.object.class
          type_name = if klass.respond_to?(:object_type)
            klass.object_type.to_s.underscore
          else
            klass.to_s.underscore
          end

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
              add_links(attrs, name, association, opts)
            else
              add_link(attrs, name, association, opts)
            end

            if @options[:embed] != :ids && options[:add_linked]
              Array(association).each do |association|
                add_linked(name, association, nil, opts)
              end
            end
          end
        end
      end
    end
  end
end
