module ActiveModel
  class Serializer
    # Defines the attributes to be serialized.
    #
    module Attributes
      extend ActiveSupport::Concern

      included do |base|
        base.class_attribute :_attributes      # @api private : names of attribute methods, @see #attribute
        base._attributes ||= []
        base.class_attribute :_attributes_keys # @api private : maps attribute value to explict key name, @see #attribute
        base._attributes_keys ||= {}
      end

      module ClassMethods
        def inherit_attributes(base)
          base._attributes = _attributes.dup
          base._attributes_keys = _attributes_keys.dup
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
        #     def recent_edits
        #       object.edits.last(5)
        #     end
        #
        # @example
        #   class AdminAuthorSerializer < ActiveModel::Serializer
        #     attribute :name do
        #       "#{object.first_name} #{object.last_name}"
        #     end
        def attribute(attr, options = {}, &block)
          key = options.fetch(:key, attr)
          _attributes_keys[attr] = { key: key } if key != attr
          _attributes << key unless _attributes.include?(key)

          ActiveModelSerializers.silence_warnings do
            define_method key do
              if block_given?
                instance_eval(&block)
              else
                object.read_attribute_for_serialization(attr)
              end
            end unless method_defined?(key) || _fragmented.respond_to?(attr)
          end
        end
      end

      # Return the +attributes+ of +object+ as presented
      # by the serializer.
      def attributes
        attributes = self.class._attributes.dup

        attributes.each_with_object({}) do |name, hash|
          if self.class._fragmented
            hash[name] = self.class._fragmented.public_send(name)
          else
            hash[name] = send(name)
          end
        end
      end
    end
  end
end
