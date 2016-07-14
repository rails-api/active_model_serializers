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
          serializer.class_attribute :_reflections, :_default_include, :_always_include
          self._reflections ||= []
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

        # Set _default_include to the parsed value of +include_args+.
        # @param include_args value to be parsed by JSONAPI::IncludeDirective::Parser
        # @param options options for JSONAPI::IncludeDirective::Parser, default { allow_wildcard: true }
        # @return [void]
        #
        def default_include(include_args, options = {})
          default_options = { allow_wildcard: true }
          self._default_include = JSONAPI::IncludeDirective.new(include_args, default_options.merge(options))
        end

        # Set _always_include to the parsed value of +include_args+.
        # @param include_args value to be parsed by JSONAPI::IncludeDirective::Parser
        # @param options options for JSONAPI::IncludeDirective::Parser, default { allow_wildcard: true }
        # @return [void]
        #
        def always_include(include_args, options = {})
          default_options = { allow_wildcard: true }
          self._always_include = JSONAPI::IncludeDirective.new(include_args, default_options.merge(options))
        end

        private

        # Add reflection and define {name} accessor.
        # @param [ActiveModel::Serializer::Reflection] reflection
        # @return [void]
        #
        # @api private
        #
        def associate(reflection)
          _reflections << reflection
        end
      end

      # Instance method to get _default_include
      def default_include
        _default_include
      end

      # Instance method to get _always_include
      def always_include
        _always_include
      end

      # @param [JSONAPI::IncludeDirective] include_directive (defaults to the
      #   +default_include_directive+ config value when not provided)
      # @return [Enumerator<Association>]
      #
      def associations(include_directive = ActiveModelSerializers.default_include_directive)
        return unless object

        include_directive.merge!(always_include) if always_include

        Enumerator.new do |y|
          self.class._reflections.each do |reflection|
            next if reflection.excluded?(self)
            key = reflection.options.fetch(:key, reflection.name)
            next unless include_directive.key?(key)
            y.yield reflection.build_association(self, instance_options)
          end
        end
      end
    end
  end
end
