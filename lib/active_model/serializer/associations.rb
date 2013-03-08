module ActiveModel
  class Serializer
    module Associations #:nodoc:
      class Config #:nodoc:
        class_attribute :options

        def self.refine(name, class_options)
          current_class = self

          Class.new(self) do
            singleton_class.class_eval do
              define_method(:to_s) do
                "(subclass of #{current_class.name})"
              end

              alias inspect to_s
            end

            self.options = class_options
          end
        end

        self.options = {}

        def initialize(name, source, options={})
          @name = name
          @source = source
          @options = options
        end

        def option(key, default=nil)
          if @options.key?(key)
            @options[key]
          elsif self.class.options.key?(key)
            self.class.options[key]
          else
            default
          end
        end

        def target_serializer
          serializer = option(:serializer)
          serializer.is_a?(String) ? serializer.constantize : serializer
        end

        def source_serializer
          @source
        end

        def key
          option(:key) || @name
        end

        def root
          option(:root) || @name
        end

        def name
          option(:name) || @name
        end

        def associated_object
          option(:value) || source_serializer.send(name)
        end

        def embed_ids?
          option(:embed, source_serializer._embed) == :ids
        end

        def embed_objects?
          option(:embed, source_serializer._embed) == :objects
        end

        def embed_in_root?
          option(:include, source_serializer._root_embed)
        end

        def embeddable?
          !associated_object.nil?
        end

      protected

        def find_serializable(object)
          if target_serializer
            target_serializer.new(object, source_serializer.options)
          elsif object.respond_to?(:active_model_serializer) && (ams = object.active_model_serializer)
            ams.new(object, source_serializer.options)
          else
            object
          end
        end
      end

      class HasMany < Config #:nodoc:
        def key
          if key = option(:key)
            key
          elsif embed_ids?
            "#{@name.to_s.singularize}_ids".to_sym
          else
            @name
          end
        end

        def embed_key
          if key = option(:embed_key)
            key
          else
            :id
          end
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

      class HasOne < Config #:nodoc:
        def embeddable?
          if polymorphic? && associated_object.nil?
            false
          else
            true
          end
        end

        def polymorphic?
          option :polymorphic
        end

        def root
          if root = option(:root)
            root
          elsif polymorphic?
            associated_object.class.to_s.pluralize.demodulize.underscore.to_sym
          else
            @name.to_s.pluralize.to_sym
          end
        end

        def key
          if key = option(:key)
            key
          elsif embed_ids? && !polymorphic?
            "#{@name}_id".to_sym
          else
            @name
          end
        end

        def embed_key
          if key = option(:embed_key)
            key
          else
            :id
          end
        end

        def polymorphic_key
          associated_object.class.to_s.demodulize.underscore.to_sym
        end

        def serialize
          object = associated_object

          if object && polymorphic?
            {
              :type => polymorphic_key,
              polymorphic_key => find_serializable(object).serializable_hash
            }
          elsif object
            find_serializable(object).serializable_hash
          end
        end

        def serializables
          object = associated_object
          value = object && find_serializable(object)
          value ? [value] : []
        end

        def serialize_ids
          if polymorphic?
            if associated_object
              {
                :type => polymorphic_key,
                :id => associated_object.read_attribute_for_serialization(embed_key)
              }
            else
              nil
            end
          elsif associated_object
            associated_object.read_attribute_for_serialization(embed_key)
          else
            nil
          end
        end
      end
    end
  end
end
