module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        def serializable_hash(options = {})
          @hash = serializer.attributes

          serializer.each_association do |name, association, options|
            @hash[:links] ||= {}
            @hash[:linked] ||= {}

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
          @hash[:linked][name] ||= []
          @hash[:links][name] += serializers.map(&:id)
          @hash[:linked][name] += serializers.map { |item| item.attributes(options) }
        end

        def add_link(name, serializer, options)
          plural_name = name.to_s.pluralize.to_sym
          @hash[:linked][plural_name] ||= []

          @hash[:links][name] = serializer.id
          @hash[:linked][plural_name].push serializer.attributes(options)
        end
      end
    end
  end
end
