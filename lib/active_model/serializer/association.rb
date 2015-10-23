module ActiveModel
  class Serializer
    # This class hold all information about serializer's association.
    #
    # @param [Symbol] name
    # @param [ActiveModel::Serializer] serializer
    # @param [Hash{Symbol => Object}] options
    #
    # @example
    #  Association.new(:comments, CommentSummarySerializer)
    #
    Association = Struct.new(:name, :serializer, :options) do
      # @return [Symbol]
      #
      def key
        options.fetch(:key, name)
      end

      # @return [Boolean]
      #
      def data?
        @data ||= options.fetch(:data, true)
      end
    end
  end
end
