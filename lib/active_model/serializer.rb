require 'active_model/array_serializer'
require 'active_model/serializable'
require 'active_model/serializer/associations'
require 'active_model/serializer/configuration'
require 'active_model/serializer/dsl'

require 'forwardable'

module ActiveModel
  class Serializer
    include Serializable

    class << self
      def inherited(subclass)
        subclass.configuration = ClassConfiguration.new configuration
        subclass._attributes = (_attributes || []).dup
        subclass._associations = (_associations || {}).dup
      end

      if RUBY_VERSION >= '2.0'
        def serializer_for(resource)
          if resource.respond_to?(:to_ary)
            ArraySerializer
          else
            begin
              Object.const_get "#{resource.class.name}Serializer"
            rescue NameError
              nil
            end
          end
        end
      else
        def serializer_for(resource)
          if resource.respond_to?(:to_ary)
            ArraySerializer
          else
            "#{resource.class.name}Serializer".safe_constantize
          end
        end
      end

      attr_writer :configuration

      def configuration
        @configuration ||= ClassConfiguration.new GlobalConfiguration.instance
      end

      attr_accessor :_attributes, :_associations

      def root_name
        name.demodulize.underscore.sub(/_serializer$/, '') if name
      end

      extend Forwardable

      def_delegators :dsl, :attributes, :has_one, :has_many, :embed, :root

      private

      def dsl
        @dsl ||= DSL.new self
      end
    end

    extend Forwardable

    def_delegators :configuration, :scope, :root, :meta_key, :meta, :wrap_in_array

    attr_accessor :object, :configuration

    def initialize(object, options = {}, configuration = nil)
      @object        = object
      @configuration = InstanceConfiguration.new(configuration || self.class.configuration, options)
    end

    def json_key
      if root == true || root.nil?
        self.class.root_name
      else
        root
      end
    end

    def attributes
      filter(self.class._attributes.dup).each_with_object({}) do |name, hash|
        hash[name] = send(name)
      end
    end

    def associations
      associations = self.class._associations
      included_associations = filter(associations.keys)
      associations.each_with_object({}) do |(name, association), hash|
        if included_associations.include? name
          if association.embed_ids
            hash[association.key] = serialize_ids association
          elsif association.embed_objects
            hash[association.embedded_key] = serialize association
          end
        end
      end
    end

    def filter(keys)
      keys
    end

    def embedded_in_root_associations
      associations = self.class._associations
      included_associations = filter(associations.keys)
      associations.each_with_object({}) do |(name, association), hash|
        if included_associations.include? name
          if association.embed_in_root
            association_serializer = build_serializer(association)
            hash.merge! association_serializer.embedded_in_root_associations

            serialized_data = association_serializer.serializable_object
            key = association.root_key
            if hash.has_key?(key)
              hash[key].concat(serialized_data).uniq!
            else
              hash[key] = serialized_data
            end
          end
        end
      end
    end

    def build_serializer(association)
      object = send(association.name)
      association.build_serializer(object, scope: scope)
    end

    def serialize(association)
      build_serializer(association).serializable_object
    end

    def serialize_ids(association)
      associated_data = send(association.name)
      if associated_data.respond_to?(:to_ary)
        associated_data.map { |elem| elem.read_attribute_for_serialization(association.embed_key) }
      else
        associated_data.read_attribute_for_serialization(association.embed_key) if associated_data
      end
    end

    def serializable_object(options={})
      return nil if object.nil?
      hash = attributes
      hash.merge! associations
      wrap_in_array ? [hash] : hash
    end
    alias_method :serializable_hash, :serializable_object
  end
end
