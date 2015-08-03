require 'active_support/core_ext/class/attribute'
require 'set'

module ActiveModel
  class Serializer
    # Defines an attribute on the object should be rendered
    #
    # The serializer object should implement the attribute name
    # as a method which should return a value when invoked. If a method
    # with the attribute name does not exist, the attribute name is
    # dispatched to the serialized object.
    #
    module Attributes
      extend ActiveSupport::Concern

      included do |base|
        class_attribute :_attributes, instance_reader: false, instance_writer: false
        class_attribute :_attributes_keys, instance_reader: false, instance_writer: false
        base._attributes = Set.new
        base._attributes_keys = {}
      end

      # @param [Hash] options
      # @option options [Array<Symbol>] :fields
      # @option options [Array<Symbol>] :required_fields
      # @return [Hash<Symbol => any>] attribute name to value mapping
      #
      def attributes(options = {})
        attributes =
          if options[:fields]
            self.class._attributes & options[:fields]
          else
            self.class._attributes.dup
          end

        attributes += options[:required_fields] if options[:required_fields]

        attributes.each_with_object({}) do |name, hash|
          if self.class._fragmented
            hash[name] = self.class._fragmented.public_send(name)
          else
            hash[name] = send(name)
          end
        end
      end

      module ClassMethods
        def inherited(base)
          base._attributes = _attributes.dup
          base._attributes_keys = _attributes_keys.dup
          super
        end

        # Define list of serializer's attributes
        # @param [Array<Symbol>] attrs
        # @return [void]
        #
        # @example
        #   attributes :name, :email
        #
        def attributes(*attrs)
          _options = attrs.extract_options! # Ignore options

          attrs.each do |attr|
            define_attribute(attr)
          end
        end

        # Define serializer's attributes
        # @param [Array<Symbol>] name
        # @param [Hash] options
        # @option options [Symbol] :key (+name+) alias of the attribute
        # @return [void]
        #
        # @example
        #   attributes :name
        #
        # @example override attribute's key
        #   attributes :name, key: :first_name
        #
        def attribute(name, options = {})
          define_attribute(name, options)
        end

        private

        # @param [Symbol] name
        # @param [Hash] options
        # @option options [Symbol] :key (+name+) alias of the attribute
        #
        def define_attribute(name, options = {})
          key = options.fetch(:key, name)
          _attributes_keys[name] = { key: key } if key != name
          _attributes << key

          define_method key do
            object && object.read_attribute_for_serialization(name)
          end unless method_defined?(key) || _fragmented.respond_to?(name)
        end
      end
    end
  end
end
