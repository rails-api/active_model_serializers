module ActiveModel
  class Serializer
    class Adapter
      class FlattenJson < Json
        def serializable_hash(options = {})
          super
          @result
        end

        private

        # no-op: FlattenJson adapter does not include meta data, because it does not support root.
        def include_meta(json)
          json
        end
      end
    end
  end
end
