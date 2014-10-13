module ActiveModel
  class Serializer
    class Adapter
      class Json < Adapter
        def serializable_hash(options = {})
          @hash = serializer.attributes(options)

          serializer.each_association do |name, association, options|
            if association.respond_to?(:each)
              array_serializer = association
              @hash[name] = array_serializer.map { |item| item.attributes(options) }
            else
              @hash[name] = association.attributes(options)
            end
          end

          @hash
        end
      end
    end
  end
end
