require 'active_model/default_serializer'
require 'active_model/serializable'

module ActiveModel
  class ArraySerializer
    include Serializable

    class << self
      attr_accessor :_root
      alias root  _root=
      alias root= _root=
    end

    def initialize(object, options={})
      @object          = object
      @scope           = options[:scope]
      @root            = options.fetch(:root, self.class._root)
      @polymorphic     = options.fetch(:polymorphic, false)
      @meta_key        = options[:meta_key] || :meta
      @meta            = options[@meta_key]
      @each_serializer = options[:each_serializer]
      @resource_name   = options[:resource_name]
      @only            = options[:only] ? Array(options[:only]) : nil
      @except          = options[:except] ? Array(options[:except]) : nil
      @context         = options[:context]
      @namespace       = options[:namespace]
      @key_format      = options[:key_format] || options[:each_serializer].try(:key_format)
    end
    attr_accessor :object, :scope, :root, :meta_key, :meta, :key_format, :context

    def json_key
      key = root.nil? ? @resource_name : root

      key_format == :lower_camel && key.present? ? key.camelize(:lower) : key
    end

    def serializer_for(item)
      serializer_class = @each_serializer || Serializer.serializer_for(item, namespace: @namespace) || DefaultSerializer
      serializer_class.new(item, scope: scope, key_format: key_format, context: @context, only: @only, except: @except, polymorphic: @polymorphic, namespace: @namespace)
    end

    def serializable_object(options={})
      @object.map do |item|
        serializer_for(item).serializable_object_with_notification(options)
      end
    end
    alias_method :serializable_array, :serializable_object

    def embedded_in_root_associations
      @object.each_with_object({}) do |item, hash|
        serializer_for(item).embedded_in_root_associations.each_pair do |type, objects|
          next if !objects || objects.flatten.empty?

          if hash.has_key?(type)
            case hash[type] when Hash
              hash[type].deep_merge!(objects){ |key, old, new| (Array(old) + Array(new)).uniq }
            else
              hash[type].concat(objects).uniq!
            end
          else
            hash[type] = objects
          end
        end
      end
    end

    private

    def instrumentation_keys
      [:object, :scope, :root, :meta_key, :meta, :each_serializer, :resource_name, :key_format, :context]
    end
  end
end
