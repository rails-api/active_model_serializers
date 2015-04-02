module ActiveModel
  class Serializer
    class Adapter
      class Json < Adapter
        def serializable_hash(options = {})
          if serializer.respond_to?(:each)
            @result = serializer.map{|s| self.class.new(s, options.merge(@options)).serializable_hash }
          else
            @result = cached_object do
              @hash = serializer.attributes(options.merge(@options))
              serializer.each_association do |name, association, opts|
                if association.respond_to?(:each)
                  array_serializer = association
                  @hash[name] = array_serializer.map { |item| item.attributes(opts.merge(@options)) }
                else
                  if association
                    @hash[name] = association.attributes(options)
                  else
                    @hash[name] = nil
                  end
                end
              end
              @hash
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
