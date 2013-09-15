require 'active_model/array_serializer'
require 'active_model/serializable'
require 'active_model/serializer/associations'
require 'active_model/serializer/settings'

module ActiveModel
  class Serializer
    include Serializable

    class << self
      def inherited(base)
        base._attributes = []
        base._associations = []
      end

      def setup
        yield SETTINGS
      end

      def serializer_for(resource)
        if resource.respond_to?(:to_ary)
          ArraySerializer
        else
          "#{resource.class.name}Serializer".safe_constantize
        end
      end

      attr_accessor :_root, :_attributes, :_associations
      alias root  _root=
      alias root= _root=

      def root_name
        name.demodulize.underscore.sub(/_serializer$/, '') if name
      end

      def attributes(*attrs)
        @_attributes.concat attrs.map(&:to_s)

        attrs.each do |attr|
          unless method_defined?(attr)
            define_method attr do
              object.read_attribute_for_serialization(attr)
            end
          end
        end
      end

      def has_one(*attrs)
        associate(Association::HasOne, *attrs)
      end

      def has_many(*attrs)
        associate(Association::HasMany, *attrs)
      end

      private

      def associate(klass, *attrs)
        options = attrs.extract_options!

        attrs.each do |attr|
          attr = attr.to_s

          unless method_defined?(attr)
            define_method attr do
              object.send attr
            end
          end

          @_associations << klass.new(attr, options)
        end
      end
    end

    def initialize(object, options={})
      @object   = object
      @scope    = options[:scope]
      self.root = options[:root]
      @meta_key = options[:meta_key] || :meta
      @meta     = options[@meta_key]
    end
    attr_accessor :object, :scope, :meta_key, :meta
    attr_reader :root

    alias read_attribute_for_serialization send

    def root=(root)
      @root = root
      @root = self.class._root if @root.nil?
      @root = self.class.root_name if @root == true || @root.nil?
    end

    def attributes
      self.class._attributes.each_with_object({}) do |name, hash|
        hash[name] = send(name)
      end
    end

    def associations
      self.class._associations.each_with_object({}) do |association, hash|
        if association.embed_ids?
          hash[association.key] = serialize_ids association
        elsif association.embed_objects?
          hash[association.embedded_key] = serialize association
        end
      end
    end

    def serializable_data
      embedded_in_root_associations.merge!(super)
    end

    def embedded_in_root_associations
      self.class._associations.each_with_object({}) do |association, hash|
        if association.embed_in_root?
          hash[association.embedded_key] = serialize association
        end
      end
    end

    def serialize(association)
      associated_data = send(association.name)
      if associated_data.respond_to?(:to_ary)
        associated_data.map { |elem| association.build_serializer(elem).serializable_hash }
      else
        [association.build_serializer(associated_data).serializable_hash]
      end
    end

    def serialize_ids(association)
      associated_data = send(association.name)
      if associated_data.respond_to?(:to_ary)
        associated_data.map { |elem| elem.send(association.embed_key) }
      else
        associated_data.send(association.embed_key)
      end
    end

    def serializable_hash(options={})
      return nil if object.nil?
      hash = attributes
      hash.merge! associations
    end
    alias serializable_object serializable_hash
  end
end
