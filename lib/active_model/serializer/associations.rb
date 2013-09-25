module ActiveModel
  class Serializer
    class Association #:nodoc:
      # name: The name of the association.
      #
      # options: A hash. These keys are accepted:
      #
      #   value: The object we're associating with.
      #
      #   serializer: The class used to serialize the association.
      #
      #   embed: Define how associations should be embedded.
      #      - :objects                 # Embed associations as full objects.
      #      - :ids                     # Embed only the association ids.
      #      - :ids, include: true      # Embed the association ids and include objects in the root.
      #
      #   include: Used in conjunction with embed :ids. Includes the objects in the root.
      #
      #   root: Used in conjunction with include: true. Defines the key used to embed the objects.
      #
      #   key: Key name used to store the ids in.
      #
      #   embed_key: Method used to fetch ids. Defaults to :id.
      #
      #   polymorphic: Is the association is polymorphic?. Values: true or false.
      def initialize(name, options={}, serializer_options={})
        @name          = name
        @object        = options[:value]

        embed          = options[:embed]
        @embed_ids     = embed == :id || embed == :ids
        @embed_objects = embed == :object || embed == :objects
        @embed_key     = options[:embed_key] || :id
        @embed_in_root = options[:include]

        serializer = options[:serializer]
        @serializer_class = serializer.is_a?(String) ? serializer.constantize : serializer

        @options = options
        @serializer_options = serializer_options
      end

      attr_reader :object, :root, :name, :embed_ids, :embed_objects, :embed_in_root
      alias embeddable? object
      alias embed_objects? embed_objects
      alias embed_ids? embed_ids
      alias use_id_key? embed_ids?
      alias embed_in_root? embed_in_root

      def key
        if key = options[:key]
          key
        elsif use_id_key?
          id_key
        else
          name
        end
      end

      private

      attr_reader :embed_key, :serializer_class, :options, :serializer_options

      def find_serializable(object)
        if serializer_class
          serializer_class.new(object, serializer_options)
        elsif object.respond_to?(:active_model_serializer) && (ams = object.active_model_serializer)
          ams.new(object, serializer_options)
        else
          DefaultSerializer.new(object, serializer_options)
        end
      end

      class HasMany < Association #:nodoc:
        def root
          options[:root] || name
        end

        def id_key
          "#{name.to_s.singularize}_ids".to_sym
        end

        def serializables
          object.map do |item|
            find_serializable(item)
          end
        end

        def serialize
          object.map do |item|
            find_serializable(item).serializable_hash
          end
        end

        def serialize_ids
          object.map do |item|
            serializer = find_serializable(item)
            if serializer.respond_to?(embed_key)
              serializer.send(embed_key)
            else
              item.read_attribute_for_serialization(embed_key)
            end
          end
        end
      end

      class HasOne < Association #:nodoc:
        def initialize(name, options={}, serializer_options={})
          super
          @polymorphic = options[:polymorphic]
        end

        def root
          if root = options[:root]
            root
          elsif polymorphic?
            object.class.to_s.pluralize.demodulize.underscore.to_sym
          else
            name.to_s.pluralize.to_sym
          end
        end

        def id_key
          "#{name}_id".to_sym
        end

        def embeddable?
          super || !polymorphic?
        end

        def serializables
          value = object && find_serializable(object)
          value ? [value] : []
        end

        def serialize
          if object
            if polymorphic?
              {
                :type => polymorphic_key,
                polymorphic_key => find_serializable(object).serializable_hash
              }
            else
              find_serializable(object).serializable_hash
            end
          end
        end

        def serialize_ids
          if object
            serializer = find_serializable(object)
            id =
              if serializer.respond_to?(embed_key)
                serializer.send(embed_key)
              else
                object.read_attribute_for_serialization(embed_key)
              end

            if polymorphic?
              {
                type: polymorphic_key,
                id: id
              }
            else
              id
            end
          end
        end

        private

        attr_reader :polymorphic
        alias polymorphic? polymorphic

        def use_id_key?
          embed_ids? && !polymorphic?
        end

        def polymorphic_key
          object.class.to_s.demodulize.underscore.to_sym
        end
      end
    end
  end
end
