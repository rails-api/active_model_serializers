require 'thread_safe'
require 'active_model/serializer/array_serializer'
require 'active_model/serializer/include_tree'
require 'active_model/serializer/associations'
require 'active_model/serializer/configuration'
require 'active_model/serializer/fieldset'
require 'active_model/serializer/lint'

module ActiveModel
  class Serializer
    include Configuration
    include Associations
    require 'active_model/serializer/adapter'

    # Matches
    #  "c:/git/emberjs/ember-crm-backend/app/serializers/lead_serializer.rb:1:in `<top (required)>'"
    #  AND
    #  "/c/git/emberjs/ember-crm-backend/app/serializers/lead_serializer.rb:1:in `<top (required)>'"
    #  AS
    #  c/git/emberjs/ember-crm-backend/app/serializers/lead_serializer.rb
    CALLER_FILE = /
      \A       # start of string
      \S+      # one or more non-spaces
      (?=      # stop previous match when
        :\d+     # a colon is followed by one or more digits
        :in      # followed by a colon followed by in
      )
    /x

    with_options instance_writer: false, instance_reader: false do |serializer|
      class_attribute :_type, instance_reader: true
      class_attribute :_attributes
      self._attributes ||= []
      class_attribute :_attributes_keys
      self._attributes_keys ||= {}
      class_attribute :_attributes_values
      self._attributes_values ||= {}
      serializer.class_attribute :_cache
      serializer.class_attribute :_fragmented
      serializer.class_attribute :_cache_key
      serializer.class_attribute :_cache_only
      serializer.class_attribute :_cache_except
      serializer.class_attribute :_cache_options
      serializer.class_attribute :_cache_digest
    end

    def self.inherited(base)
      base._attributes = _attributes.dup
      base._attributes_keys = _attributes_keys.dup
      base._attributes_values = _attributes_values.dup
      base._cache_digest = digest_caller_file(caller.first)
      super
    end

    def self.type(type)
      self._type = type
    end

    def self.attributes(*attrs)
      attrs = attrs.first if attrs.first.class == Array

      attrs.each do |attr|
        attribute(attr)
      end
    end

    def self.attribute(attr, options = {}, &block)
      key = options.fetch(:key, attr)
      _attributes_keys[attr] = { key: key }
      _attributes << attr unless _attributes.include?(key)
      _attributes_values[attr] = block if block_given?
    end

    def self.fragmented(serializer)
      self._fragmented = serializer
    end

    # Enables a serializer to be automatically cached
    def self.cache(options = {})
      self._cache = ActionController::Base.cache_store if Rails.configuration.action_controller.perform_caching
      self._cache_key = options.delete(:key)
      self._cache_only = options.delete(:only)
      self._cache_except = options.delete(:except)
      self._cache_options = (options.empty?) ? nil : options
    end

    def self.serializer_for(resource, options = {})
      if resource.respond_to?(:serializer_class)
        resource.serializer_class
      elsif resource.respond_to?(:to_ary)
        config.array_serializer
      else
        options.fetch(:serializer) { get_serializer_for(resource.class) }
      end
    end

    # @see ActiveModel::Serializer::Adapter.lookup
    def self.adapter
      ActiveModel::Serializer::Adapter.lookup(config.adapter)
    end

    def self.serializers_cache
      @serializers_cache ||= ThreadSafe::Cache.new
    end

    def self.digest_caller_file(caller_line)
      serializer_file_path = caller_line[CALLER_FILE]
      serializer_file_contents = IO.read(serializer_file_path)
      Digest::MD5.hexdigest(serializer_file_contents)
    end

    # @api private
    def self.serializer_lookup_chain_for(klass)
      chain = []

      resource_class_name = klass.name.demodulize
      resource_namespace = klass.name.deconstantize
      serializer_class_name = "#{resource_class_name}Serializer"

      chain.push("#{name}::#{serializer_class_name}") if self != ActiveModel::Serializer
      chain.push("#{resource_namespace}::#{serializer_class_name}")

      chain
    end

    # @api private
    def self.get_serializer_for(klass)
      serializers_cache.fetch_or_store(klass) do
        # NOTE(beauby): When we drop 1.9.3 support we can lazify the map for perfs.
        serializer_class = serializer_lookup_chain_for(klass).map(&:safe_constantize).find { |x| x }

        if serializer_class
          serializer_class
        elsif klass.superclass
          get_serializer_for(klass.superclass)
        end
      end
    end

    attr_accessor :object, :root, :scope

    def initialize(object, options = {})
      self.object = object
      self.instance_options = options
      self.root = instance_options[:root]
      self.scope = instance_options[:scope]

      scope_name = instance_options[:scope_name]
      if scope_name && !respond_to?(scope_name)
        self.class.class_eval do
          define_method scope_name, lambda { scope }
        end
      end
    end

    def json_key
      root || object.class.model_name.to_s.underscore
    end

    def attribute_value(name)
      if self.class._attributes_values[name]
        instance_eval(&self.class._attributes_values[name])
      elsif respond_to?(name) # To handle legacy method-based attr overriding
        warn 'Overriding attributes by defining a method on the serializer is deprecated. Please use the block syntax.'
        public_send(name)
      else
        object.read_attribute_for_serialization(name)
      end
    end

    def attributes
      attributes = self.class._attributes.dup

      attributes.each_with_object({}) do |name, hash|
        key = self.class._attributes_keys[name][:key]
        klass = self.class._fragmented || self
        hash[key] = klass.attribute_value(name)
      end
    end

    protected

    attr_accessor :instance_options
  end
end
