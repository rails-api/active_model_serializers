require 'active_model/array_serializer'
require 'active_model/serializable'
require 'active_model/serializer/association'
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

      def serializer_for(resource, options = {})
        if resource.respond_to?(:serializer_class)
          resource.serializer_class
        elsif resource.respond_to?(:to_ary)
          if Object.constants.include?(:ArraySerializer)
            ::ArraySerializer
          else
            ArraySerializer
          end
        else
          _const_get build_serializer_class(resource, options)
        end
      end

      attr_accessor :_root, :_attributes, :_associations
      alias root  _root=
      alias root= _root=

      def root_name
        if name
          root_name = name.demodulize.underscore.sub(/_serializer$/, '')
          CONFIG.plural_default_root ? root_name.pluralize : root_name
        end
      end

      def attributes(*attrs)
        attrs.each do |attr|
          striped_attr = strip_attribute attr

          @_attributes << striped_attr

          define_method striped_attr do
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

      def strip_attribute(attr)
        symbolized = attr.is_a?(Symbol)

        attr = attr.to_s.gsub(/\?\Z/, '')
        attr = attr.to_sym if symbolized
        attr
      end

      def build_serializer_class(resource, options)
        "".tap do |klass_name|
          klass_name << "#{options[:namespace]}::" if options[:namespace]
          klass_name << options[:prefix].to_s.classify if options[:prefix]
          klass_name << "#{resource.class.name}Serializer"
        end
      end

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
      @polymorphic   = options.fetch(:polymorphic, false)
      @meta_key      = options[:meta_key] || :meta
      @meta          = options[@meta_key]
      @wrap_in_array = options[:_wrap_in_array]
      @only          = options[:only] ? Array(options[:only]) : nil
      @except        = options[:except] ? Array(options[:except]) : nil
      @key_format    = options[:key_format]
      @context       = options[:context]
      @namespace     = options[:namespace]
    end
    attr_accessor :object, :scope, :root, :meta_key, :meta, :key_format, :context, :polymorphic

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

    def associations(options={})
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
            hash[association.embedded_key] = serialize association, options
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
          association_serializer = build_serializer(association)
          # we must do this always because even if the current association is not
          # embeded in root, it might have its own associations that are embeded in root
          hash.merge!(association_serializer.embedded_in_root_associations) do |key, oldval, newval|
            if oldval.respond_to?(:to_ary)
              [oldval, newval].flatten.uniq
            else
              oldval.merge(newval) { |_, oldval, newval| [oldval, newval].flatten.uniq }
            end
          end

          if association.embed_in_root?
            if association.embed_in_root_key?
              hash = hash[association.embed_in_root_key] ||= {}
            end

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
      association.build_serializer(object, association_options_for_serializer(association))
    end

    def association_options_for_serializer(association)
      prefix    = association.options[:prefix]
      namespace = association.options[:namespace] || @namespace || self.namespace

      { scope: scope }.tap do |opts|
        opts[:namespace] = namespace if namespace
        opts[:prefix]    = prefix    if prefix
      end
    end

    def serialize(association,options={})
      build_serializer(association).serializable_object(options)
    end

    def serialize_ids(association)
      associated_data = send(association.name)
      if associated_data.respond_to?(:to_ary)
        associated_data.map { |elem| serialize_id(elem, association) }
      else
        serialize_id(associated_data, association) if associated_data
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

    attr_writer :serialization_options
    def serialization_options
      @serialization_options || {}
    end

    def serializable_object(options={})
      self.serialization_options = options
      return @wrap_in_array ? [] : nil if @object.nil?
      hash = attributes
      hash.merge! associations(options)
      hash = convert_keys(hash) if key_format.present?
      hash = { :type => type_name(@object), type_name(@object) => hash } if @polymorphic
      @wrap_in_array ? [hash] : hash
    end
    alias_method :serializable_hash, :serializable_object

    def serialize_id(elem, association)
      id = elem.read_attribute_for_serialization(association.embed_key)
      association.polymorphic? ? { id: id, type: type_name(elem) } : id
    end

    def type_name(elem)
      elem.class.to_s.demodulize.underscore.to_sym
    end
  end

end
