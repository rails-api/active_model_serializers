module ActiveModel
  class Serializer
    class PaginationSerializer < ArraySerializer
      attr_reader :page_size, :page_number

      def initialize(objects, options = {})
        @page_size   = options.delete(:page_size)
        @page_number = options.delete(:page_number)

        super

        @objects = @objects.first.instance_variable_get('@objects')
      end
    end
  end
end
