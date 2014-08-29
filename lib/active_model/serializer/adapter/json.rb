module ActiveModel
  class Serializer
    class Adapter
      class Json < Adapter
        def serializable_hash(options = {})
          @hash = serializer.attributes

          serializer.associations.each do |name, association|
            if association.respond_to?(:each)
              @hash[name] = association.map(&:attributes)
            else
              @hash[name] = association.attributes
            end
          end
          @hash
        end
      end
    end
  end
end
