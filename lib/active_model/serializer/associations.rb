module ActiveModel
  class Serializer
    # Defines an association in the object should be rendered.
    #
    # The serializer object should implement the association name
    # as a method which should return an array when invoked. If a method
    # with the association name does not exist, the association name is
    # dispatched to the serialized object.
    #
    module Associations
      extend ActiveSupport::Concern

      DEFAULT_INCLUDE_TREE = ActiveModel::Serializer::IncludeTree.from_string('*')

      included do |base|
        base.class_attribute :serialized_associations, instance_writer: false # @api public: maps association name to 'Reflection' instance
        base.serialized_associations ||= {}
        base.class_attribute :_reflections, instance_writer: false
        base._reflections ||= []

        extend ActiveSupport::Autoload
        autoload :Association
        autoload :Reflection
        autoload :SingularReflection
        autoload :CollectionReflection
        autoload :BelongsToReflection
        autoload :HasOneReflection
        autoload :HasManyReflection
      end

      module ClassMethods
        # Serializers inherit _reflections.
        def inherited(base)
          super
          base._reflections = _reflections.dup
        end

        # @param [Symbol] name of the association
        # @param [Hash<Symbol => any>] options for the reflection
        # @return [void]
        #
        # @example
        #  has_many :comments, serializer: CommentSummarySerializer
        #
        def has_many(name, options = {}, &block)
          associate(HasManyReflection.new(name, options), block)
        end

        # @param [Symbol] name of the association
        # @param [Hash<Symbol => any>] options for the reflection
        # @return [void]
        #
        # @example
        #  belongs_to :author, serializer: AuthorSerializer
        #
        def belongs_to(name, options = {}, &block)
          associate(BelongsToReflection.new(name, options), block)
        end

        # @param [Symbol] name of the association
        # @param [Hash<Symbol => any>] options for the reflection
        # @return [void]
        #
        # @example
        #  has_one :author, serializer: AuthorSerializer
        #
        def has_one(name, options = {}, &block)
          associate(HasOneReflection.new(name, options), block)
        end

        private

        # Add reflection and define {name} accessor.
        # @param [ActiveModel::Serializer::Reflection] reflection
        # @return [void]
        #
        # @api private
        #
        def associate(reflection, block)
          self._reflections = _reflections.dup

          reflection_name = reflection.name
          if block
            serialized_associations[reflection_name] = ->(instance) { instance.instance_eval(&block) }
          else
            serialized_associations[reflection_name] = ->(instance) { instance.object.send(reflection_name) }
          end

          define_method reflection_name do
            serialized_associations[reflection_name].call(self)
          end unless method_defined?(reflection_name)

          self._reflections << reflection
        end
      end

      # @param [IncludeTree] include_tree (defaults to all associations when not provided)
      # @return [Enumerator<Association>]
      #
      def associations(include_tree = DEFAULT_INCLUDE_TREE)
        return unless object

        Enumerator.new do |y|
          self.class._reflections.each do |reflection|
            key = reflection.options.fetch(:key, reflection.name)
            next unless include_tree.key?(key)
            y.yield reflection.build_association(self, instance_options)
          end
        end
      end
    end
  end
end
