module ActiveModel
  class Serializer
    class Adapter
      class Json < Adapter
        def serializable_hash(options = {})
          if serializer.respond_to?(:each)
            @result = serializer.map{|s| self.class.new(s).serializable_hash }
          else
            @result = serializer.attributes(options)

            serializer.each_association do |name, association, opts|
              if association.respond_to?(:each)
                array_serializer = association
                @result[name] = array_serializer.map { |item| item.attributes(opts) }
              else
                @result[name] = association.attributes(options)
              end
            end
          end

          if root = options.fetch(:root, serializer.json_key)
            @result = { root => @result }
          end

          @result
        end
      end
    end
  end
end
