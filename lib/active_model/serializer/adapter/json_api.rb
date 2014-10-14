module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        def initialize(serializer, options = {})
          super
          serializer.root ||= true
        end

        def serializable_hash(opts = {})
          @hash = attributes_for_serializer(serializer, {})

          serializer.each_association do |name, association, options|
            @hash[:links] ||= {}
            unless options[:embed] == :ids
              @hash[:linked] ||= {}
            end

            if association.respond_to?(:each)
              add_links(name, association, options)
            else
              add_link(name, association, options)
            end
          end

          @hash
        end

        def add_links(name, serializers, options)
          @hash[:links][name] ||= []
          @hash[:links][name] += serializers.map{|serializer| serializer.id.to_s }

          unless options[:embed] == :ids
            @hash[:linked][name] ||= []
            @hash[:linked][name] += serializers.map { |item| attributes_for_serializer(item, options) }
          end
        end

        def add_link(name, serializer, options)
          @hash[:links][name] = serializer.id.to_s

          unless options[:embed] == :ids
            plural_name = name.to_s.pluralize.to_sym

            @hash[:linked][plural_name] ||= []
            @hash[:linked][plural_name].push attributes_for_serializer(serializer, options)
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
