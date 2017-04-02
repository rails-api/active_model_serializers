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
      # @return [Symbol]
      def key
        options.fetch(:key, name)
      end

      # @return [ActiveModel::Serializer, nil]
      def serializer
        options[:serializer]
      end

      # @return [Hash]
      def links
        options.fetch(:links) || {}
      end

      # @return [Hash, nil]
      def meta
        options[:meta]
      end

      # @api private
      def serializable_hash(adapter_options, adapter_instance)
        return options[:virtual_value] if options[:virtual_value]
        object = serializer && serializer.object
        return unless object

        serialization = serializer.serializable_hash(adapter_options, {}, adapter_instance)

        if options[:polymorphic] && serialization
          polymorphic_type = object.class.name.underscore
          serialization = { type: polymorphic_type, polymorphic_type.to_sym => serialization }
        end

        serialization
      end
    end
  end
end
