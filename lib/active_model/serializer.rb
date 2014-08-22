require 'active_model/array_serializer'
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
        base._root = _root
        base._attributes = (_attributes || []).dup
        base._associations = (_associations || {}).dup
      end

      def setup
        @mutex.synchronize do
          yield CONFIG
        end
      end

      EMBED_IN_ROOT_OPTIONS = [
        :include,
        :embed_in_root,
        :embed_in_root_key,
        :embed_namespace
      ].freeze

      def embed(type, options={})
        CONFIG.embed = type
        if EMBED_IN_ROOT_OPTIONS.any? { |opt| options[opt].present? }
          CONFIG.embed_in_root = true
        end
        if options[:embed_in_root_key].present?
          CONFIG.embed_in_root_key = options[:embed_in_root_key]
        end
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

      def format_keys(format)
        @key_format = format
      end
      attr_reader :key_format

      if RUBY_VERSION >= '2.0'
        def serializer_for(resource)
          if resource.respond_to?(:to_ary)
            if Object.constants.include?(:ArraySerializer)
              ::ArraySerializer
            else
              ArraySerializer
            end
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
            if Object.constants.include?(:ArraySerializer)
              ::ArraySerializer
            else
              ArraySerializer
            end
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
          define_method attr do
            object.read_attribute_for_serialization attr
          end unless method_defined?(attr)
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
          define_method attr do
            object.send attr
          end unless method_defined?(attr)

          @_associations[attr] = klass.new(attr, options)
        end
      end
    end

    def initialize(object, options={})
      @object        = object
      @scope         = options[:scope]
      @root          = options.fetch(:root, self.class._root)
      @meta_key      = options[:meta_key] || :meta
      @meta          = options[@meta_key]
      @wrap_in_array = options[:_wrap_in_array]
      @only          = options[:only] ? Array(options[:only]) : nil
      @except        = options[:except] ? Array(options[:except]) : nil
      @key_format    = options[:key_format]
      @context       = options[:context]
    end
    attr_accessor :object, :scope, :root, :meta_key, :meta, :key_format, :context

    def json_key
      key = if root == true || root.nil?
        self.class.root_name
      else
        root
      end

      key_format == :lower_camel && key.present? ? key.camelize(:lower) : key
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
            ids = serialize_ids association
            if association.embed_namespace?
              hash = hash[association.embed_namespace] ||= {}
              hash[association.key] = ids
            else
              hash[association.key] = ids
            end
          elsif association.embed_objects?
            if association.embed_namespace?
              hash = hash[association.embed_namespace] ||= {}
            end
            hash[association.embedded_key] = serialize association
          end
        end
      end
    end

    def filter(keys)
      if @only
        keys & @only
      elsif @except
        keys - @except
      else
        keys
      end
    end

    def embedded_in_root_associations
      associations = self.class._associations
      included_associations = filter(associations.keys)
      associations.each_with_object({}) do |(name, association), hash|
        if included_associations.include? name
          if association.embed_in_root?
            if association.embed_in_root_key?
              hash = hash[association.embed_in_root_key] ||= {}
            end
            association_serializer = build_serializer(association)
            hash.merge!(association_serializer.embedded_in_root_associations) {|key, oldval, newval| [newval, oldval].flatten }

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

    def key_format
      @key_format || self.class.key_format || CONFIG.key_format
    end

    def format_key(key)
      if key_format == :lower_camel
        key.to_s.camelize(:lower)
      else
        key
      end
    end

    def convert_keys(hash)
      Hash[hash.map do |k,v|
        key = if k.is_a?(Symbol)
          format_key(k).to_sym
        else
          format_key(k)
        end

        [key ,v]
      end]
    end

    def serializable_object(options={})
      return @wrap_in_array ? [] : nil if @object.nil?
      hash = attributes
      hash.merge! associations
      hash = convert_keys(hash) if key_format.present?
      @wrap_in_array ? [hash] : hash
    end
    alias_method :serializable_hash, :serializable_object
  end

end
