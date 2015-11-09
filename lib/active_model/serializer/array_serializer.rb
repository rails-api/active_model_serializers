require 'active_model/serializer/collection_serializer'
class ActiveModel::Serializer
  class ArraySerializer < CollectionSerializer
    def initialize(*)
      warn "Calling deprecated ArraySerializer in #{caller[0..2].join(', ')}. Please use CollectionSerializer"
      super
    end
  end
end
