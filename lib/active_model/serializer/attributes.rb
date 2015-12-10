module ActiveModel
  class Serializer
    module Attributes
      extend ActiveSupport::Concern

      included do
        with_options instance_writer: false, instance_reader: false do |serializer|
          serializer.class_attribute :_attribute_mappings # @api private : maps attribute key names to names to names of implementing methods, @see #attribute
          self._attribute_mappings ||= {}
          serializer.class_attribute :_attribute_keys # @api private : maps attribute names to keys, @see #attribute
          self._attribute_keys ||= {}
        end

        # Return the +attributes+ of +object+ as presented
        # by the serializer.
        def attributes(requested_attrs = nil, reload = false)
          @attributes = nil if reload
          @attributes ||= self.class._attribute_keys.each_with_object({}) do |(name, key), hash|
            next unless requested_attrs.nil? || requested_attrs.include?(key)
            hash[key] = self.class._attribute_mappings[name].call(self)
          end
        end
      end

      module ClassMethods
        def inherited(base)
          super
          base._attribute_mappings = _attribute_mappings.dup
          base._attribute_keys = _attribute_keys.dup
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
          _attribute_keys[attr] = options.fetch(:key, attr)
          _attribute_mappings[attr] = _attribute_mapping(attr, block)
        end

        # @api private
        def _attribute_mapping(name, block)
          if block
            ->(instance) { instance.instance_eval(&block) }
          else
            ->(instance) { instance.read_attribute_for_serialization(name) }
          end
        end

        # @api private
        # keys of attributes
        # @see Serializer::attribute
        def _attributes
          _attribute_keys.values
        end

        # @api private
        # maps attribute value to explict key name
        # @see Serializer::attribute
        # @see Adapter::FragmentCache#fragment_serializer
        def _attributes_keys
          _attribute_keys
            .each_with_object({}) do |(name, key), hash|
              next if key == name
              hash[name] = { key: key }
            end
        end
      end
    end
  end
end
