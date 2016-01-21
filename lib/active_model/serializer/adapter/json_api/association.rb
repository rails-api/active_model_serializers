module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class Association
          def initialize(parent_serializer, serializer, options, links, meta)
            @object = parent_serializer.object
            @scope = parent_serializer.scope

            @options = options
            @data = data_for(serializer, options)
            @links = links
                     .map { |key, value| { key => Link.new(parent_serializer, value).as_json } }
                     .reduce({}, :merge)
            @meta = meta.respond_to?(:call) ? parent_serializer.instance_eval(&meta) : meta
          end

          def as_json
            hash = {}
            hash[:data] = @data if @options[:include_data]
            hash[:links] = @links if @links.any?
            hash[:meta] = @meta if @meta

            hash
          end

          protected

          attr_reader :object, :scope

          private

          def data_for(serializer, options)
            if serializer.respond_to?(:each)
              serializer.map { |s| ResourceIdentifier.new(s).as_json }
            else
              if options[:virtual_value]
                options[:virtual_value]
              elsif serializer && serializer.object
                ResourceIdentifier.new(serializer).as_json
              end
            end
          end
        end
      end
    end
  end
end
