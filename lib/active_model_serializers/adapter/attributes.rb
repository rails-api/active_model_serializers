# frozen_string_literal: true

module ActiveModelSerializers
  module Adapter
    class Attributes < Base
      def initialize(*)
        super
        instance_options[:fieldset] ||= ActiveModel::Serializer::Fieldset.new(fields_to_fieldset(instance_options.delete(:fields)))
      end

      def serializable_hash(options = nil)
        options = serialization_options(options)
        options[:fields] ||= instance_options[:fields]
        serialized_hash = serializer.serializable_hash(instance_options, options, self)

        self.class.transform_key_casing!(serialized_hash, instance_options)
      end

      private

      def fields_to_fieldset(fields)
        return fields if fields.nil?
        resource_fields = []
        relationship_fields = {}
        fields.each do |field|
          case field
          when Symbol, String then resource_fields << field
          when Hash then relationship_fields.merge!(field)
          else fail ArgumentError, "Unknown conversion of fields to fieldset: '#{field.inspect}' in '#{fields.inspect}'"
          end
        end
        relationship_fields.merge!(serializer.json_key.to_sym => resource_fields)
      end
    end
  end
end
