module ActiveModel
  class Serializer
    class Adapter
      class JsonApi < Adapter
        class Links
          def initialize(links = {})
            @links = links
          end

          def serializable_hash
            @links
          end

          def update(links = {})
            @links.update(links)
          end

          def present?
            !@links.empty?
          end
        end
      end
    end
  end
end
