require 'thread_safe'

module ActiveModel
  class Serializer
    extend ActiveSupport::Autoload
    autoload :Configuration
    autoload :ArraySerializer
    autoload :Adapter
    include Configuration

    class << self
      attr_accessor :_attributes
      attr_accessor :_attributes_keys
      attr_accessor :_associations
      attr_accessor :_urls
      attr_accessor :_cache
      attr_accessor :_fragmented
      attr_accessor :_cache_key
      attr_accessor :_cache_only
      attr_accessor :_cache_except
      attr_accessor :_cache_options
    end

    def self.inherited(base)
      base._attributes = self._attributes.try(:dup)  || []
      base._attributes_keys = self._attributes_keys.try(:dup) || {}
      base._associations = self._associations.try(:dup) || {}
      base._urls = []
    end

    def self.attributes(*attrs)
      attrs = attrs.first if attrs.first.class == Array
      @_attributes.concat attrs
      @_attributes.uniq!

      attrs.each do |attr|
        define_method attr do
          object && object.read_attribute_for_serialization(attr)
        end unless method_defined?(attr) || _fragmented.respond_to?(attr)
      end
    end

    def self.attribute(attr, options = {})
      key = options.fetch(:key, attr)
      @_attributes_keys[attr] = {key: key} if key != attr
      @_attributes << key unless @_attributes.include?(key)
      define_method key do
        object.read_attribute_for_serialization(attr)
      end unless method_defined?(key) || _fragmented.respond_to?(attr)
    end

    def self.fragmented(serializer)
      @_fragmented = serializer
    end

    # Enables a serializer to be automatically cached
    def self.cache(options = {})
      @_cache         = ActionController::Base.cache_store if Rails.configuration.action_controller.perform_caching
      @_cache_key     = options.delete(:key)
      @_cache_only    = options.delete(:only)
      @_cache_except  = options.delete(:except)
      @_cache_options = (options.empty?) ? nil : options
    end

    # Defines an association in the object should be rendered.
    #
    # The serializer object should implement the association name
    # as a method which should return an array when invoked. If a method
    # with the association name does not exist, the association name is
    # dispatched to the serialized object.
    def self.has_many(*attrs)
      associate(:has_many, attrs)
    end

    # Defines an association in the object that should be rendered.
    #
    # The serializer object should implement the association name
    # as a method which should return an object when invoked. If a method
    # with the association name does not exist, the association name is
    # dispatched to the serialized object.
    def self.belongs_to(*attrs)
      associate(:belongs_to, attrs)
    end

    # Defines an association in the object should be rendered.
    #
    # The serializer object should implement the association name
    # as a method which should return an object when invoked. If a method
    # with the association name does not exist, the association name is
    # dispatched to the serialized object.
    def self.has_one(*attrs)
      associate(:has_one, attrs)
    end

    def self.associate(type, attrs) #:nodoc:
      options = attrs.extract_options!
      self._associations = _associations.dup

      attrs.each do |attr|
        unless method_defined?(attr)
          define_method attr do
            object.send attr
          end
        end

        self._associations[attr] = {type: type, association_options: options}
      end
    end

    def self.url(attr)
      @_urls.push attr
    end

    def self.urls(*attrs)
      @_urls.concat attrs
    end

    def self.serializer_for(resource, options = {})
      if resource.respond_to?(:serializer_class)
        resource.serializer_class
      elsif resource.respond_to?(:to_ary)
        config.array_serializer
      else
        options
          .fetch(:association_options, {})
          .fetch(:serializer, get_serializer_for(resource.class))
      end
    end

    def self.adapter
      adapter_class = case config.adapter
      when Symbol
        ActiveModel::Serializer::Adapter.adapter_class(config.adapter)
      when Class
        config.adapter
      end
      unless adapter_class
        valid_adapters = Adapter.constants.map { |klass| ":#{klass.to_s.downcase}" }
        raise ArgumentError, "Unknown adapter: #{config.adapter}. Valid adapters are: #{valid_adapters}"
      end

      adapter_class
    end

    def self._root
      @@root ||= false
    end

    def self._root=(root)
      @@root = root
    end

    def self.root_name
      name.demodulize.underscore.sub(/_serializer$/, '') if name
    end

    attr_accessor :object, :root, :meta, :meta_key, :scope

    def initialize(object, options = {})
      @object     = object
      @options    = options
      @root       = options[:root] || (self.class._root ? self.class.root_name : false)
      @meta       = options[:meta]
      @meta_key   = options[:meta_key]
      @scope      = options[:scope]

      scope_name = options[:scope_name]
      if scope_name && !respond_to?(scope_name)
        self.class.class_eval do
          define_method scope_name, lambda { scope }
        end
      end
    end

    def json_key
      if root == true || root.nil?
        self.class.root_name
      else
        root
      end
    end

    def id
      object.id if object
    end

    def type
      object.class.to_s.demodulize.underscore.pluralize
    end

    def attributes(options = {})
      attributes =
        if options[:fields]
          self.class._attributes & options[:fields]
        else
          self.class._attributes.dup
        end

      attributes += options[:required_fields] if options[:required_fields]

      attributes.each_with_object({}) do |name, hash|
        unless self.class._fragmented
          hash[name] = send(name)
        else
          hash[name] = self.class._fragmented.public_send(name)
        end
      end
    end

    def each_association(&block)
      self.class._associations.dup.each do |name, association_options|
        next unless object
        association_value = send(name)

        serializer_class = ActiveModel::Serializer.serializer_for(association_value, association_options)

        if serializer_class
          serializer = serializer_class.new(
            association_value,
            options.merge(serializer_from_options(association_options))
          )
        elsif !association_value.nil? && !association_value.instance_of?(Object)
          association_options[:association_options][:virtual_value] = association_value
        end

        if block_given?
          block.call(name, serializer, association_options[:association_options])
        end
      end
    end

    def serializer_from_options(options)
      opts = {}
      serializer = options.fetch(:association_options, {}).fetch(:serializer, nil)
      opts[:serializer] = serializer if serializer
      opts
    end

    def self.serializers_cache
      @serializers_cache ||= ThreadSafe::Cache.new
    end

    private

    attr_reader :options

    def self.get_serializer_for(klass)
      serializers_cache.fetch_or_store(klass) do
        serializer_class_name = "#{klass.name}Serializer"
        serializer_class = serializer_class_name.safe_constantize

        if serializer_class
          serializer_class
        elsif klass.superclass
          get_serializer_for(klass.superclass)
        end
      end
    end

  end
end
