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

      included do |base|
        class << base
          attr_accessor :_reflections
        end

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

        # @param [Array(Array<Symbol>, Hash{Symbol => Object})] attrs
        # @return [void]
        #
        # @example
        #  has_many :comments, serializer: CommentSummarySerializer
        #  has_many :commits, authors
        #
        def has_many(*attrs)
          associate attrs do |name, options|
            HasManyReflection.new(name, options)
          end
        end

        # @param [Array(Array<Symbol>, Hash{Symbol => Object})] attrs
        # @return [void]
        #
        # @example
        #  belongs_to :author, serializer: AuthorSerializer
        #
        def belongs_to(*attrs)
          associate attrs do |name, options|
            BelongsToReflection.new(name, options)
          end
        end

        # @param [Array(Array<Symbol>, Hash{Symbol => Object})] attrs
        # @return [void]
        #
        # @example
        #  has_one :author, serializer: AuthorSerializer
        #
        def has_one(*attrs)
          associate attrs do |name, options|
            HasOneReflection.new(name, options)
          end
        end

        private

        # Add reflection and define {name} accessor.
        # @param [Array<Symbol>]
        # @yield [Symbol] return reflection
        #
        # @api private
        #
        def associate(attrs)
          options = attrs.extract_options!

          self._reflections = _reflections.dup

          attrs.each do |name|
            unless method_defined?(name)
              define_method name do
                object.send name
              end
            end

            self._reflections << yield(name, options)
          end
        end
      end

      # @return [Enumerator<Association>]
      #
      def associations
        return unless object

        Enumerator.new do |y|
          reflections.each do |reflection|
            y.yield reflection.build_association(self, options)
          end
        end
      end

      def reflections
        self.class._reflections
      end
    end
  end
end
