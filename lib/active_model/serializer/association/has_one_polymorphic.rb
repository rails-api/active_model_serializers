module ActiveModel
  class Serializer
    class Association
      class HasOnePolymorphic < HasOne
        include IsPolymorphic
      end
    end
  end
end
