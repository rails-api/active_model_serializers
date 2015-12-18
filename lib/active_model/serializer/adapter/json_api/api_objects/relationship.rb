module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        module ApiObjects
          class Relationship
            # NOTE(beauby): Currently only `data` is used.
            attr_accessor :data, :meta, :links

            def initialize(hash = {})
              hash.each { |k, v| send("#{k}=", v) }
            end

            def to_h
              data_hash =
                if data.is_a?(Array)
                  data.map { |ri| ri.respond_to?(:to_h) ? ri.to_h : ri }
                elsif data
                  data.respond_to?(:to_h) ? data.to_h : data
                end

              { data: data_hash }
            end
          end
        end
      end
    end
  end
end
