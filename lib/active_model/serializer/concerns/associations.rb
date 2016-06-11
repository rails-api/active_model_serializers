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

      included do
        with_options instance_writer: false, instance_reader: true do |serializer|
          serializer.class_attribute :_reflections
          self._reflections ||= {}
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
        def has_many(name, options = {}, &block) # rubocop:disable Style/PredicateName
          associate(HasManyReflection.new(name, options, block))
        end

        # @param [Symbol] name of the association
        # @param [Hash<Symbol => any>] options for the reflection
        # @return [void]
        #
        # @example
        #  belongs_to :author, serializer: AuthorSerializer
        #
        def belongs_to(name, options = {}, &block)
          associate(BelongsToReflection.new(name, options, block))
        end

        # @param [Symbol] name of the association
        # @param [Hash<Symbol => any>] options for the reflection
        # @return [void]
        #
        # @example
        #  has_one :author, serializer: AuthorSerializer
        #
        def has_one(name, options = {}, &block) # rubocop:disable Style/PredicateName
          associate(HasOneReflection.new(name, options, block))
        end

        private

        # Add reflection and define {name} accessor.
        # @param [ActiveModel::Serializer::Reflection] reflection
        # @return [void]
        #
        # @api private
        #
        def associate(reflection)
          key = reflection.options[:key] || reflection.name
          self._reflections[key] = reflection
        end
      end

      # @param [JSONAPI::IncludeDirective] include_directive (defaults to the
      #   +default_include_directive+ config value when not provided)
      # @return [Enumerator<Association>]
      #
      def associations(include_directive = ActiveModelSerializers.default_include_directive, include_slice = nil)
        include_slice ||= include_directive
        return unless object

        Enumerator.new do |y|
          self.class._reflections.values.each do |reflection|
            next if reflection.excluded?(self)
            key = reflection.options.fetch(:key, reflection.name)
            next unless include_directive.key?(key)

            y.yield reflection.build_association(self, instance_options, include_slice)
          end
        end
      end
    end
  end
end
