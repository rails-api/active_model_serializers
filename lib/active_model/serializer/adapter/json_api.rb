module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        def serializable_hash(options = {})
          @hash = serializer.attributes

          serializer.associations.each do |name, association|
            @hash[:links] ||= {}
            @hash[:linked] ||= {}
            if association.respond_to?(:each)
              add_links(name, association)
            else
              add_link(name, association)
            end
          end
          @hash
        end

        def add_links(name, serializers)
          @hash[:links][name] ||= []
          @hash[:linked][name] ||= []
          @hash[:links][name] += serializers.map(&:id)
          @hash[:linked][name] += serializers.map(&:attributes)
        end

        def add_link(name, serializer)
          plural_name = name.to_s.pluralize.to_sym
          @hash[:linked][plural_name] ||= []

          @hash[:links][name] = serializer.id
          @hash[:linked][plural_name].push serializer.attributes
        end
      end
    end
  end
end
