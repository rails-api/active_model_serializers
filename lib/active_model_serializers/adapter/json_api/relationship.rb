module ActiveModelSerializers
  module Adapter
    class JsonApi
      class Relationship
        # {http://jsonapi.org/format/#document-resource-object-related-resource-links Document Resource Object Related Resource Links}
        # {http://jsonapi.org/format/#document-links Document Links}
        # {http://jsonapi.org/format/#document-resource-object-linkage Document Resource Relationship Linkage}
        # {http://jsonapi.org/format/#document-meta Docment Meta}
        def initialize(parent_serializer, serializer, serializable_resource_options, args = {})
          @object = parent_serializer.object
          @scope = parent_serializer.scope
          @association_options = args.fetch(:options, {})
          @serializable_resource_options = serializable_resource_options
          @data = data_for(serializer)
          @links = args.fetch(:links, {}).each_with_object({}) do |(key, value), hash|
            hash[key] = ActiveModelSerializers::Adapter::JsonApi::Link.new(parent_serializer, value).as_json
          end
          meta = args.fetch(:meta, nil)
          @meta = meta.respond_to?(:call) ? parent_serializer.instance_eval(&meta) : meta
        end

        def as_json
          hash = {}
          hash[:data] = data if association_options[:include_data]
          links = self.links
          hash[:links] = links if links.any?
          meta = self.meta
          hash[:meta] = meta if meta

          hash
        end

        protected

        attr_reader :object, :scope, :data, :serializable_resource_options,
          :association_options, :links, :meta

        private

        def data_for(serializer)
          if serializer.respond_to?(:each)
            serializer.map { |s| ResourceIdentifier.new(s, serializable_resource_options).as_json }
          elsif association_options[:virtual_value]
            association_options[:virtual_value]
          elsif serializer && serializer.object
            ResourceIdentifier.new(serializer, serializable_resource_options).as_json
          end
        end
      end
    end
  end
end
