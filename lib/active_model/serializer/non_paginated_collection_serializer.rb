require 'active_model/serializer/collection_serializer'

module ActiveModel
  class Serializer
    class NonPaginatedCollectionSerializer < CollectionSerializer
      def paginated?
        false
      end
    end
  end
end
