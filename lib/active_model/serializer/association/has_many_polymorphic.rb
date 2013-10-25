module ActiveModel
  class Serializer
    class Association
      class HasManyPolymorphic < HasMany
        include IsPolymorphic
      end
    end
  end
end