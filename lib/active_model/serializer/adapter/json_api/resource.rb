module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        Resource = Struct.new(:identifier, :attributes, :relationships, :links) do
          def to_h
            hash = identifier.to_h
            hash[:attributes] = attributes if attributes.any?
            hash[:relationships] = Hash[relationships.map { |k, v| [k, v.to_h] }] if relationships.any?
            hash[:links] = links if links.any?

            hash
          end
        end
      end
    end
  end
end
