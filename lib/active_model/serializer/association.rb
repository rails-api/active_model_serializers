require 'active_model/serializer/lazy_association'

module ActiveModel
  class Serializer
    # This class holds all information about serializer's association.
    #
    # @attr [Symbol] name
    # @attr [Hash{Symbol => Object}] options
    # @attr [block]
    #
    # @example
    #  Association.new(:comments, { serializer: CommentSummarySerializer })
    #
    class Association < Field
      attr_reader :lazy_association
      delegate :include_data?, :virtual_value, to: :lazy_association

      def initialize(*)
        super
        @lazy_association = LazyAssociation.new(name, options, block)
      end

      # @return [Symbol]
      def key
        options.fetch(:key, name)
      end

      # @return [True,False]
      def key?
        options.key?(:key)
      end

      # @return [Hash]
      def links
        options.fetch(:links) || {}
      end

      # @return [Hash, nil]
      def meta
        options[:meta]
      end

      def polymorphic?
        true == options[:polymorphic]
      end

      # @api private
      def serializable_hash(adapter_options, adapter_instance)
        association_serializer = lazy_association.serializer
        return virtual_value if virtual_value
        association_object = association_serializer && association_serializer.object
        return unless association_object

        serialization = association_serializer.serializable_hash(adapter_options, {}, adapter_instance)

        if polymorphic? && serialization
          polymorphic_type = association_object.class.name.underscore
          serialization = { type: polymorphic_type, polymorphic_type.to_sym => serialization }
        end

        serialization
      end

      private

      delegate :reflection, to: :lazy_association
    end
  end
end
