require 'thread_safe'

module ActiveModel
  class Serializer
    extend ActiveSupport::Autoload

    autoload :Configuration
    autoload :ArraySerializer
    autoload :Adapter
    autoload :Lint
    autoload :Associations
    include Configuration
    include Associations

    class << self
      attr_accessor :_attributes
      attr_accessor :_params
      attr_accessor :_attributes_keys
      attr_accessor :_urls
      attr_accessor :_cache
      attr_accessor :_fragmented
      attr_accessor :_cache_key
      attr_accessor :_cache_only
      attr_accessor :_cache_except
      attr_accessor :_cache_options
      attr_accessor :_cache_digest
    end

    def self.inherited(base)
      base._attributes = self._attributes.try(:dup) || []
      base._attributes_keys = self._attributes_keys.try(:dup) || {}
      base._params = self._attributes.try(:dup) || []
      base._urls = []

      serializer_file = File.open(caller.first[/^[^:]+/])
      base._cache_digest = Digest::MD5.hexdigest(serializer_file.read)
      super
    end

    def self.params(*attrs)
      @_params.concat attrs
      @_params.uniq!
    end

    def self.attributes(*attrs)
      attrs = attrs.first if attrs.first.class == Array
      @_attributes.concat attrs
      @_attributes.uniq!
      @_params = @_attributes

      attrs.each do |attr|
        define_method attr do
          object && object.read_attribute_for_serialization(attr)
        end unless method_defined?(attr) || _fragmented.respond_to?(attr)
      end
    end

    def self.attribute(attr, options = {})
      key = options.fetch(:key, attr)
      @_attributes_keys[attr] = { key: key } if key != attr
      @_attributes << key unless @_attributes.include?(key)
      @_params << key unless @_params.include?(key)

      unless respond_to?(key, false) || _fragmented.respond_to?(attr)
        define_method key do
          object.read_attribute_for_serialization(attr)
        end
      end
    end

    def self.fragmented(serializer)
      @_fragmented = serializer
    end

    # Enables a serializer to be automatically cached
    def self.cache(options = {})
      @_cache = ActionController::Base.cache_store if Rails.configuration.action_controller.perform_caching
      @_cache_key = options.delete(:key)
      @_cache_only = options.delete(:only)
      @_cache_except = options.delete(:except)
      @_cache_options = (options.empty?) ? nil : options
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
        options.fetch(:serializer, get_serializer_for(resource.class))
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

    def self.root_name
      name.demodulize.underscore.sub(/_serialization$/, '') if name
    end

    def self.deserialize(params)
      association_keys = _reflections.map(&:name)
      permitted_params = adapter.params(@_params, association_keys) || @_params
      permitted_key    = adapter.root || root_name

      sanitazed_params = params.require(permitted_key.to_sym).permit(permitted_params)
      adapter.parse(sanitazed_params)
    end

    def self.sanitize_params(params, whitelist = nil)
      attrs = @_params
      assocs = _reflections.map(&:name)
      forbid_id = false
      if whitelist
        assocs &= whitelist
        attrs &= whitelist
        forbid_id = !whitelist.include?(:id)
      end
      permitted_params = adapter.params_whitelist(attrs, assocs, forbid_id)
      permitted_key = adapter.root || root_name

      params.require(permitted_key.to_sym).permit(permitted_params)
    end

    def self.deserialize(params, whitelist = nil)
      whitelist = whitelist.map { |x| x.to_sym } if whitelist
      sanitized_params = sanitize_params(params, whitelist)
      adapter.parse(sanitized_params)
    end

    attr_accessor :object, :root, :meta, :meta_key, :scope

    def initialize(object, options = {})
      @object = object
      @options = options
      @root = options[:root]
      @meta = options[:meta]
      @meta_key = options[:meta_key]
      @scope = options[:scope]

      scope_name = options[:scope_name]
      if scope_name && !respond_to?(scope_name)
        self.class.class_eval do
          define_method scope_name, lambda { scope }
        end
      end
    end

    def json_key
      @root || object.class.model_name.to_s.underscore
    end

    def id
      object.id if object
    end

    def json_api_type
      object.class.model_name.plural
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

    def self.serializers_cache
      @serializers_cache ||= ThreadSafe::Cache.new
    end

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
