require 'active_model/serializer/collection_serializer'
class ActiveModel::Serializer
  class ArraySerializer < CollectionSerializer
    class << self
      extend ActiveModelSerializers::Deprecate
      deprecate :new, 'ActiveModel::Serializer::CollectionSerializer.'
    end
  end
end
