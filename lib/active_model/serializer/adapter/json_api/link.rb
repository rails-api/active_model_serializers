module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class Link
          def initialize(serializer)
            @object = serializer.object
            @scope = serializer.scope
          end

          def href(value)
            self._href = value
          end

          def meta(value)
            self._meta = value
          end

          def to_hash
            hash = { href: _href }
            hash.merge!(meta: _meta) if _meta

            hash
          end

          protected

          attr_accessor :_href, :_meta
          attr_reader :object, :scope
        end
      end
    end
  end
end
