module ActiveModel
  class Serializer
    module Attributes
      extend ActiveSupport::Concern

      included do
        with_options instance_writer: false, instance_reader: false do |serializer|
          serializer.class_attribute :_attributes_data # @api private
          self._attributes_data ||= {}
        end

        extend ActiveSupport::Autoload
        autoload :Attribute

        # Return the +attributes+ of +object+ as presented
        # by the serializer.
        def attributes(requested_attrs = nil, reload = false)
          @attributes = nil if reload
          @attributes ||= self.class._attributes_data.each_with_object({}) do |(key, attr), hash|
            next if attr.excluded?(self)
            next unless requested_attrs.nil? || requested_attrs.include?(key)
            hash[key] = attr.value(self)
          end
        end
      end

      module ClassMethods
        def inherited(base)
          super
          base._attributes_data = _attributes_data.dup
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
          _attributes_data[key] = Attribute.new(attr, options, block)
        end

        # @api private
        # keys of attributes
        # @see Serializer::attribute
        def _attributes
          _attributes_data.keys
        end

        # @api private
        # maps attribute value to explict key name
        # @see Serializer::attribute
        # @see FragmentCache#fragment_serializer
        def _attributes_keys
          _attributes_data
            .each_with_object({}) do |(key, attr), hash|
              next if key == attr.name
              hash[attr.name] = { key: key }
            end
        end
      end
    end
  end
end
