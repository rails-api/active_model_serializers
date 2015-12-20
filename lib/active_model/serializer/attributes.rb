module ActiveModel
  class Serializer
    module Attributes
      extend ActiveSupport::Concern

      included do
        with_options instance_writer: false, instance_reader: false do |serializer|
          serializer.class_attribute :_attribute_procs # @api private : maps attribute key names to names to names of implementing methods, @see #attribute
          self._attribute_procs ||= {}
          serializer.class_attribute :_attribute_keys # @api private : maps attribute names to keys, @see #attribute
          self._attribute_keys ||= {}
        end

        # Return the +attributes+ of +object+ as presented
        # by the serializer.
        def attributes(requested_attrs = nil, reload = false)
          @attributes = nil if reload
          @attributes ||= self.class._attribute_keys.each_with_object({}) do |(name, key), hash|
            next unless requested_attrs.nil? || requested_attrs.include?(key)
            hash[key] = _attribute_value(name)
          end
        end

        # @api private
        def _attribute_value(name)
          if self.class._attribute_procs[name]
            instance_eval(&self.class._attribute_procs[name])
          else
            read_attribute_for_serialization(name)
          end
        end
      end

      module ClassMethods
        def inherited(base)
          super
          base._attribute_procs = _attribute_procs.dup
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
          _attribute_procs[attr] = block
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
