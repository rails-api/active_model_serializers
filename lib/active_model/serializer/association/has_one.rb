module ActiveModel
  class Serializer
    class Association
      class HasOne < Association
        def initialize(*args)
          super
          @key  ||= "#{name}_id"
        end
      end
    end
  end
end
