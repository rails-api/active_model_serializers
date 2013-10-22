require 'active_model/array_serializer'
require 'active_model/hash_serializer'
require 'active_model/serializable'
require 'active_model/serializer/associations'
require 'active_model/serializer/config'

require 'thread'

module ActiveModel
  class Serializer
    include Serializable

    @mutex = Mutex.new

    class << self
      def inherited(base)
        base._attributes = []
        base._associations = {}
      end

      def setup
        @mutex.synchronize do
          yield CONFIG
        end
      end

      def embed(type, options={})
        CONFIG.embed = type
        CONFIG.embed_in_root = true if options[:embed_in_root] || options[:include]
        ActiveSupport::Deprecation.warn <<-WARN
** Notice: embed is deprecated. **
The use of .embed method on a Serializer will be soon removed, as this should have a global scope and not a class scope.
Please use the global .setup method instead:
ActiveModel::Serializer.setup do |config|
  config.embed = :#{type}
  config.embed_in_root = #{CONFIG.embed_in_root || false}
end
        WARN
      end

      if RUBY_VERSION >= '2.0'
        def serializer_for(resource)
          if resource.respond_to?(:to_ary)
            ArraySerializer
          elsif resource.respond_to?(:has_key?)
            HashSerializer
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
          elsif resource.respond_to?(:has_key?)
            HashSerializer
          else
            "#{resource.class.name}Serializer".safe_constantize
          end
        end
      end

      attr_accessor :_root, :_attributes, :_associations
      alias root  _root=
      alias root= _root=

      def root_name
        name.demodulize.underscore.sub(/_serializer$/, '') if name
      end

      def attributes(*attrs)
        @_attributes.concat attrs

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
          unless method_defined?(attr)
            define_method attr do
              object.send attr
            end
          end

          @_associations[attr] = klass.new(attr, options)
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

    def root=(root)
      @root = root
      @root = self.class._root if @root.nil?
      @root = self.class.root_name if @root == true || @root.nil?
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
          if association.embed_ids?
            hash[association.key] = serialize_ids association
          elsif association.embed_objects?
            hash[association.embedded_key] = serialize association
          end
        end
      end
    end

    def filter(keys)
      keys
    end

    def serializable_data
      embedded_in_root_associations.merge!(super)
    end

    def embedded_in_root_associations
      associations = self.class._associations
      included_associations = filter(associations.keys)
      associations.each_with_object({}) do |(name, association), hash|
        if included_associations.include? name
          if association.embed_in_root?
            hash[association.embedded_key] = serialize association
          end
        end
      end
    end

    def serialize(association)
      associated_data = send(association.name)
      if associated_data.respond_to?(:to_ary)
        associated_data.map { |elem| association.build_serializer(elem).serializable_hash }
      else
        result = association.build_serializer(associated_data).serializable_hash
        association.is_a?(Association::HasMany) ? [result] : result
      end
    end

    def serialize_ids(association)
      associated_data = send(association.name)
      if associated_data.respond_to?(:to_ary)
        associated_data.map { |elem| elem.read_attribute_for_serialization(association.embed_key) }
      else
        associated_data.read_attribute_for_serialization(association.embed_key) if associated_data
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
