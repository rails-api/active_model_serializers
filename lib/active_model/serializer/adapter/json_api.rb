module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        def initialize(serializer, options = {})
          super
          serializer.root = true
        end

        def serializable_hash(options = {})
          @root = (options[:root] || serializer.json_key.to_s.pluralize).to_sym
          @hash = {}

          if serializer.respond_to?(:each)
            @hash[@root] = serializer.map{|s| self.class.new(s).serializable_hash[@root] }
          else
            @hash[@root] = attributes_for_serializer(serializer, {})

            serializer.each_association do |name, association, opts|
              @hash[@root][:links] ||= {}
              unless opts[:embed] == :ids
                @hash[:linked] ||= {}
              end

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

          unless options[:embed] == :ids
            @hash[:linked][name] ||= []
            @hash[:linked][name] += serializers.map { |item| attributes_for_serializer(item, options) }
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

            unless options[:embed] == :ids
              plural_name = name.to_s.pluralize.to_sym

              @hash[:linked][plural_name] ||= []
              @hash[:linked][plural_name].push attributes_for_serializer(serializer, options)
            end
          else
            @hash[@root][:links][name] = nil
          end
        end

        private

        def attributes_for_serializer(serializer, options)
          attributes = serializer.attributes(options)
          attributes[:id] = attributes[:id].to_s if attributes[:id]
          attributes
        end
      end
    end
  end
end
