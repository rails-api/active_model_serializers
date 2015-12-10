module ActiveModel
  class Serializer
    module Attributes
      # @api private
      class Attribute
        delegate :call, to: :reader

        attr_reader :name, :reader

        def initialize(name)
          @name = name
          @reader = :no_reader
        end

        def self.build(name, block)
          if block
            AttributeBlock.new(name, block)
          else
            AttributeReader.new(name)
          end
        end
      end
      # @api private
      class AttributeReader < Attribute
        def initialize(name)
          super(name)
          @reader = ->(instance) { instance.read_attribute_for_serialization(name) }
        end
      end
      # @api private
      class AttributeBlock < Attribute
        def initialize(name, block)
          super(name)
          @reader = ->(instance) { instance.instance_eval(&block) }
        end
      end

      extend ActiveSupport::Concern

      included do
        with_options instance_writer: false, instance_reader: false do |serializer|
          serializer.class_attribute :_attribute_mappings # @api private : maps attribute key names to names to names of implementing methods, @see #attribute
          self._attribute_mappings ||= {}
        end

        # Return the +attributes+ of +object+ as presented
        # by the serializer.
        def attributes(requested_attrs = nil, reload = false)
          @attributes = nil if reload
          @attributes ||= self.class._attribute_mappings.each_with_object({}) do |(key, attribute_mapping), hash|
            next unless requested_attrs.nil? || requested_attrs.include?(key)
            hash[key] = attribute_mapping.call(self)
          end
        end
      end

      module ClassMethods
        def inherited(base)
          super
          base._attribute_mappings = _attribute_mappings.dup
        end

        # @example
        #   class AdminAuthorSerializer < ActiveModel::Serializer
        #     attributes :id, :name, :recent_edits
        def attributes(*attrs)
          attrs = attrs.first if attrs.first.class == Array

          attrs.each do |attr|
            attribute(attr)
          end
        end

        # @example
        #   class AdminAuthorSerializer < ActiveModel::Serializer
        #     attributes :id, :recent_edits
        #     attribute :name, key: :title
        #
        #     attribute :full_name do
        #       "#{object.first_name} #{object.last_name}"
        #     end
        #
        #     def recent_edits
        #       object.edits.last(5)
        #     end
        def attribute(attr, options = {}, &block)
          key = options.fetch(:key, attr)
          _attribute_mappings[key] = Attribute.build(attr, block)
        end

        # @api private
        # names of attribute methods
        # @see Serializer::attribute
        def _attributes
          _attribute_mappings.keys
        end

        # @api private
        # maps attribute value to explict key name
        # @see Serializer::attribute
        # @see Adapter::FragmentCache#fragment_serializer
        def _attributes_keys
          _attribute_mappings
            .each_with_object({}) do |(key, attribute_mapping), hash|
              next if key == attribute_mapping.name
              hash[attribute_mapping.name] = { key: key }
            end
        end
      end
    end
  end
end
