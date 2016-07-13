module ActiveModel
  class Serializer
    # This class hold all information about serializer's association.
    #
    # @attr [Symbol] name
    # @attr [ActiveModel::Serializer] serializer
    # @attr [Hash{Symbol => Object}] options
    #
    # @example
    #  Association.new(:comments, CommentSummarySerializer)
    #
    Association = Struct.new(:name, :serializer, :options, :links, :meta) do
      # @return [Symbol]
      def key
        options.fetch(:key, name)
      end
    end
  end
end
