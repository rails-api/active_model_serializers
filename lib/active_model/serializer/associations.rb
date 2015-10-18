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
        class << base
          attr_accessor :_reflections
        end

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
          base._reflections = self._reflections.try(:dup) || []
        end

        # @param [Symbol] name of the association
        # @param [Hash<Symbol => any>] options for the reflection
        # @param [Block] optional inline definition of the serializer for this association
        # @return [void]
        #
        # @example
        #  has_many :comments, serializer: CommentSummarySerializer
        #  has_many :comments do
        #    attributes :id, :content
        #  end
        #
        def has_many(name, options = {}, &block)
          associate(HasManyReflection.new(name, options), &block)
        end

        # @param [Symbol] name of the association
        # @param [Hash<Symbol => any>] options for the reflection
        # @param [Block] optional inline definition of the serializer for this association
        # @return [void]
        #
        # @example
        #  belongs_to :author, serializer: AuthorSerializer
        #  belongs_to :author do
        #    attributes :id, :name
        #  end
        #
        def belongs_to(name, options = {}, &block)
          associate(BelongsToReflection.new(name, options), &block)
        end

        # @param [Symbol] name of the association
        # @param [Hash<Symbol => any>] options for the reflection
        # @param [Block] optional inline definition of the serializer for this association
        # @return [void]
        #
        # @example
        #  has_one :author, serializer: AuthorSerializer
        #  has_one :author do
        #    attributes :id, :name
        #  end
        #
        def has_one(name, options = {}, &block)
          associate(HasOneReflection.new(name, options), &block)
        end

        private

        # Add reflection and define {name} accessor and nested serializer.
        # @param [ActiveModel::Serializer::Reflection] reflection
        # @param [Block] optional inline definition of the serializer for this association
        # @return [void]
        #
        # @api private
        #
        def associate(reflection, &block)
          self._reflections = _reflections.dup

          define_method reflection.name do
            object.send reflection.name
          end unless method_defined?(reflection.name)

          _reflections << reflection

          define_nested_serializer(reflection.name.to_s.singularize, &block) if block_given?
        end

        # Define a nested serializer
        # @param [String] resource_name The name of the association
        # @param [Block] inline definition of the serializer for this association
        # @return [void]
        #
        # @example
        #  Namespace::PostSerializer.define_nested_serializer("comment") do
        #    attributes :id, :content
        #  end
        #
        # is equivalent to
        #  class Namespace::PostSerializer::CommentSerializer < ActiveModel::Serializer
        #    attributes :id, :content
        #  end
        #
        # @api private
        #
        def define_nested_serializer(resource_name, &block)
          serializer_name = "#{resource_name.camelize}Serializer"
          serializer = Class.new(ActiveModel::Serializer)
          serializer.class_eval(&block)
          const_set(serializer_name, serializer)
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
