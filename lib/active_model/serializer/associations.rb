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
          option(:serializer)
        end

        def source_serializer
          @source
        end

        def key
          option(:key) || @name
        end

        def root
          option(:root) || plural_key
        end

        def name
          option(:name) || @name
        end

        def associated_object
          option(:value) || source_serializer.send(name)
        end

        def embed_key?
          option(:key) != false
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
        alias plural_key key

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
          # Use pluck or select_columns if available
          # return collection.ids if collection.respond_to?(:ids)

          associated_object.map do |item|
            item.read_attribute_for_serialization(:id)
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

        def polymorphic_key
          associated_object.class.to_s.demodulize.underscore.to_sym
        end

        def plural_key
          if polymorphic?
            associated_object.class.to_s.pluralize.demodulize.underscore.to_sym
          else
            key.to_s.pluralize.to_sym
          end
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
          object = associated_object

          if object && polymorphic?
            {
              :type => polymorphic_key,
              :id => object.read_attribute_for_serialization(:id)
            }
          elsif object
            object.read_attribute_for_serialization(:id)
          else
            nil
          end
        end
      end
    end
  end
end
