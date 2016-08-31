module ActiveModel
  class Serializer
    # This class hold all information about serializer's association.
    #
    # @attr [Symbol] name
    # @attr [Hash{Symbol => Object}] options
    # @attr [block]
    #
    # @example
    #  Association.new(:comments, { serializer: CommentSummarySerializer })
    #
    class Association < Field
      attr_reader :serializer, :links, :meta

      def initialize(*)
        super

        @serializer = options.delete(:serializer)
        @links = options.delete(:links)
        @meta = options.delete(:meta)
      end

      # @return [Symbol]
      def key
        options.fetch(:key, name)
      end
    end
  end
end
