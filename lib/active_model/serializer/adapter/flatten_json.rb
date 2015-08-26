module ActiveModel
  class Serializer
    class Adapter
      class FlattenJson < Json
        private

        def rooting?
          false
        end

        def include_meta(json)
          json
        end
      end
    end
  end
end

