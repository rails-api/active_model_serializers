module ActiveModelSerializers
  module Adapter
    class JsonApi
      class Relationship
        def initialize(parent_serializer, serializer, options = {}, links = {}, meta = nil)
          @options = options
          @data    = data_for(serializer, options)
          @links   = links_for(parent_serializer, links)
          @meta    = meta_for(parent_serializer, meta)
        end

        def as_json
          hash = {}
          hash[:data] = data if options[:include_data]
          links = self.links
          hash[:links] = links if links.any?
          meta = self.meta
          hash[:meta] = meta if meta

          hash
        end

        protected

        attr_reader :data, :options, :links, :meta

        private

        def links_for(parent_serializer, links)
          links.each_with_object({}) do |(key, value), hash|
            hash[key] = Link.new(parent_serializer, value).as_json
          end
        end

        def meta_for(parent_serializer, meta)
          meta.respond_to?(:call) ? parent_serializer.instance_eval(&meta) : meta
        end

        def data_for(serializer, options)
          if serializer.respond_to?(:each)
            serializer.map { |s| ResourceIdentifier.new(s).as_json }
          elsif options[:virtual_value]
            options[:virtual_value]
          elsif serializer && serializer.object
            ResourceIdentifier.new(serializer).as_json
          end
        end
      end
    end
  end
end
