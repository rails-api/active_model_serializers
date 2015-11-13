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
        base.class_attribute :_reflections
        self._reflections ||= []

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
        def inherited(base)
          super
          base._reflections = _reflections.dup
        end

        # @param [Symbol] name of the association
        # @param [Hash<Symbol => any>] options for the reflection
        # @param [Block] optional block to customize value of the reflection
        # @return [void]
        #
        # @example
        #  has_many :comments, serializer: CommentSummarySerializer
        #
        def has_many(name, options = {}, &block)
          _reflections << HasManyReflection.new(name, options, block)
        end

        # @param [Symbol] name of the association
        # @param [Hash<Symbol => any>] options for the reflection
        # @param [Block] optional block to customize value of the reflection
        # @return [void]
        #
        # @example
        #  belongs_to :author, serializer: AuthorSerializer
        #
        def belongs_to(name, options = {}, &block)
          _reflections << BelongsToReflection.new(name, options, block)
        end

        # @param [Symbol] name of the association
        # @param [Hash<Symbol => any>] options for the reflection
        # @param [Block] optional block to customize value of the reflection
        # @return [void]
        #
        # @example
        #  has_one :author, serializer: AuthorSerializer
        #
        def has_one(name, options = {}, &block)
          _reflections << HasOneReflection.new(name, options, block)
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
