module ActiveModel
  class Serializer
    module Associations #:nodoc:
      class Base #:nodoc:
        def initialize(name, options={}, serializer_options={})
          @name = name
          @options = options
          @serializer_options = serializer_options
        end

        def target_serializer
          serializer = options[:serializer]
          serializer.is_a?(String) ? serializer.constantize : serializer
        end

        def key
          options[:key] || @name
        end

        def root
          options[:root] || @name
        end

        def name
          options[:name] || @name
        end

        def associated_object
          options[:value]
        end

        def embed_ids?
          [:id, :ids].include? options[:embed]
        end

        def embed_objects?
          [:object, :objects].include? options[:embed]
        end

        def embed_in_root?
          options[:include]
        end

        def embeddable?
          !associated_object.nil?
        end

        def embed_key
          if key = options[:embed_key]
            key
          else
            :id
          end
        end

      protected

        def find_serializable(object)
          if target_serializer
            target_serializer.new(object, serializer_options)
          elsif object.respond_to?(:active_model_serializer) && (ams = object.active_model_serializer)
            ams.new(object, serializer_options)
          else
            object
          end
        end

        attr_reader :options, :serializer_options
      end

      class HasMany < Base #:nodoc:
        def key
          if key = options[:key]
            key
          elsif embed_ids?
            id_key
          else
            @name
          end
        end

        def id_key
          "#{@name.to_s.singularize}_ids".to_sym
        end

        def serialize
          associated_object.map do |item|
            find_serializable(item).serializable_hash
          end
        end

        def serializables
          associated_object.map do |item|
            find_serializable(item)
          end
        end

        def serialize_ids
          associated_object.map do |item|
            item.read_attribute_for_serialization(embed_key)
          end
        end
      end

      class HasOne < Base #:nodoc:
        def embeddable?
          if polymorphic? && associated_object.nil?
            false
          else
            true
          end
        end

        def polymorphic?
          options[:polymorphic]
        end

        def root
          if root = options[:root]
            root
          elsif polymorphic?
            associated_object.class.to_s.pluralize.demodulize.underscore.to_sym
          else
            @name.to_s.pluralize.to_sym
          end
        end

        def key
          if key = options[:key]
            key
          elsif embed_ids? && !polymorphic?
            id_key
          else
            @name
          end
        end

        def id_key
          "#{@name}_id".to_sym
        end

        def polymorphic_key
          associated_object.class.to_s.demodulize.underscore.to_sym
        end

        def serialize
          object = associated_object

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

        def serializables
          object = associated_object
          value = object && find_serializable(object)
          value ? [value] : []
        end

        def serialize_ids
          object = associated_object

          if object
            id = object.read_attribute_for_serialization(embed_key)
            if polymorphic?
              {
                :type => polymorphic_key,
                :id => id
              }
            else
              id
            end
          end
        end
      end
    end
  end
end
