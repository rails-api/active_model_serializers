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
    end
  end
end
