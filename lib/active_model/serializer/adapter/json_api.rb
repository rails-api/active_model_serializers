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

            serializer.each_association do |name, association, opts|
              @hash[@root][:links] ||= {}

              if association.respond_to?(:each)
                add_links(name, association, opts)
              else
                add_link(name, association, opts)
              end
            end
          end

          @hash
        end

        def add_links(name, serializers, options)
          if serializers.first
            type = serializers.first.object.class.to_s.underscore.pluralize
          end
          if name.to_s == type || !type
            @hash[@root][:links][name] ||= []
            @hash[@root][:links][name] += serializers.map{|serializer| serializer.id.to_s }
          else
            @hash[@root][:links][name] ||= {}
            @hash[@root][:links][name][:type] = type
            @hash[@root][:links][name][:ids] ||= []
            @hash[@root][:links][name][:ids] += serializers.map{|serializer| serializer.id.to_s }
          end

          unless serializers.none? || @options[:embed] == :ids
            serializers.each do |serializer|
              add_linked(name, serializer)
            end
          end
        end

        def add_link(name, serializer, options)
          if serializer
            type = serializer.object.class.to_s.underscore
            if name.to_s == type || !type
              @hash[@root][:links][name] = serializer.id.to_s
            else
              @hash[@root][:links][name] ||= {}
              @hash[@root][:links][name][:type] = type
              @hash[@root][:links][name][:id] = serializer.id.to_s
            end

            unless @options[:embed] == :ids
              add_linked(name, serializer)
            end
          else
            @hash[@root][:links][name] = nil
          end
        end

        def add_linked(resource, serializer, parent = nil)
          resource_path = [parent, resource].compact.join('.')
          if include_assoc? resource_path
            plural_name = resource.to_s.pluralize.to_sym
            attrs = attributes_for_serializer(serializer, @options)
            @top[:linked] ||= {}
            @top[:linked][plural_name] ||= []
            @top[:linked][plural_name].push attrs unless @top[:linked][plural_name].include? attrs
          end

          unless serializer.respond_to?(:each)
            serializer.each_association do |name, association, opts|
              add_linked(name, association, resource) if association
            end
          end
        end

        private

        def attributes_for_serializer(serializer, options)
          attributes = serializer.attributes(options)
          attributes[:id] = attributes[:id].to_s if attributes[:id]
          attributes
        end

        def include_assoc? assoc
          @options[:include] && @options[:include].split(',').include?(assoc.to_s)
        end
      end
    end
  end
end
