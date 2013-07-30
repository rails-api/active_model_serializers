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
        @polymorphic   = options[:polymorphic] || false

        serializer = options[:serializer]
        @serializer_class = serializer.is_a?(String) ? serializer.constantize : serializer

        @options = options
        @serializer_options = serializer_options
      end

      attr_reader :object, :root, :name, :embed_ids, :embed_objects, :embed_in_root
      alias embeddable? object
      alias embed_objects? embed_objects
      alias embed_ids? embed_ids
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

      attr_reader :embed_key, :serializer_class, :options, :serializer_options, :polymorphic
      alias polymorphic? polymorphic

      def find_serializable(object)
        if serializer_class
          serializer_class.new(object, serializer_options)
        elsif object.respond_to?(:active_model_serializer) && (ams = object.active_model_serializer)
          ams.new(object, serializer_options)
        else
          object
        end
      end

      def type_name(object)
        object.class.to_s.demodulize.underscore.to_sym
      end

      def serialize_item(object)
        serializable_hash = find_serializable(object).serializable_hash
        if polymorphic?
          type_name = type_name object
          {
            :type => type_name,
            type_name => serializable_hash
          }
        else
          serializable_hash
        end
      end

      def serialization_id(object)
        serializer = find_serializable(object)
        if serializer.respond_to?(embed_key)
          serializer.send(embed_key)
        else
          object.read_attribute_for_serialization(embed_key)
        end
      end

      def serialize_id(object)
        id = serialization_id object

        if polymorphic?
          {
            type: type_name(object),
            id: id
          }
        else
          id
        end
      end

      def use_id_key?
        embed_ids? && !polymorphic?
      end

      class HasMany < Association #:nodoc:
        def roots
          if options[:root]
            [options[:root]]
          elsif polymorphic?
            object.map do |item|
              polymorphic_root_for_item(item)
            end.uniq
          else
            [name.to_s.pluralize.to_sym]
          end
        end

        def id_key
          "#{name.to_s.singularize}_ids".to_sym
        end

        def serializables_for_root(root)
          if options[:root] || !polymorphic?
            object.map do |item|
              find_serializable(item)
            end
          else
            object.select do |item|
              polymorphic_root_for_item(item) == root
            end.map do |item|
              find_serializable(item)
            end
          end
        end

        def serialize
          object.map do |item|
            serialize_item item
            if polymorphic?
              type_name = type_name item
              {
                :type => type_name,
                type_name => find_serializable(item).serializable_hash
              }
            else
              find_serializable(item).serializable_hash
            end
          end
        end

        def serialize_ids
          object.map do |item|
            serialize_id item
          end
        end

        private

        def polymorphic_root_for_item(item)
          item.class.to_s.demodulize.pluralize.underscore.to_sym
        end
      end

      class HasOne < Association #:nodoc:
        def roots
          if options[:root]
            [options[:root]]
          elsif polymorphic?
            [object.class.to_s.pluralize.demodulize.underscore.to_sym]
          else
            [name.to_s.pluralize.to_sym]
          end
        end

        def id_key
          "#{name}_id".to_sym
        end

        def embeddable?
          super || !polymorphic?
        end

        def serializables_for_root(root)
          value = object && find_serializable(object)
          value ? [value] : []
        end

        def serialize
          if object
            serialize_item object
          end
        end

        def serialize_ids
          if object
            serialize_id object
          end
        end
      end
    end
  end
end
