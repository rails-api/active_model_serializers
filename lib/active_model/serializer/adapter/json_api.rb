module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        def initialize(serializer, options = {})
          super
          serializer.root = true
        end

        def serializable_hash(options = {})
          @root = (options[:root] || serializer.json_key).to_s.pluralize.to_sym
          @hash = {}

          if serializer.respond_to?(:each)
            @hash[@root] = serializer.map{|s| self.class.new(s).serializable_hash[@root] }
          else
            @hash[@root] = serializer.attributes

            serializer.each_association do |name, association, opts|
              @hash[@root][:links] ||= {}
              unless options[:embed] == :ids
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
          @hash[@root][:links][name] ||= []
          @hash[@root][:links][name] += serializers.map(&:id)

          unless options[:embed] == :ids
            @hash[:linked][name] ||= []
            @hash[:linked][name] += serializers.map { |item| item.attributes(options) }
          end
        end

        def add_link(name, serializer, options)
          @hash[@root][:links][name] = serializer.id

          unless options[:embed] == :ids
            plural_name = name.to_s.pluralize.to_sym

            @hash[:linked][plural_name] ||= []
            @hash[:linked][plural_name].push serializer.attributes(options)
          end
        end
      end
    end
  end
end
