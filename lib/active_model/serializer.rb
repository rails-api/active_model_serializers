require 'thread_safe'
require 'active_model/serializer/adapter'
require 'active_model/serializer/array_serializer'
require 'active_model/serializer/associations'
require 'active_model/serializer/configuration'
require 'active_model/serializer/fieldset'
require 'active_model/serializer/lint'
require 'active_model/serializer/utils'

module ActiveModel
  class Serializer
    extend ActiveSupport::Autoload

    include Configuration
    include Associations

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

    class << self
      attr_accessor :_attributes
      attr_accessor :_attributes_keys
      attr_accessor :_cache
      attr_accessor :_fragmented
      attr_accessor :_cache_key
      attr_accessor :_cache_only
      attr_accessor :_cache_except
      attr_accessor :_cache_options
      attr_accessor :_cache_digest
    end

    def self.inherited(base)
      base._attributes = _attributes.try(:dup) || []
      base._attributes_keys = _attributes_keys.try(:dup) || {}
      base._cache_digest = digest_caller_file(caller.first)
      super
    end

    def self.attributes(*attrs)
      attrs = attrs.first if attrs.first.class == Array

      attrs.each do |attr|
        attribute(attr)
      end
    end

    def self.attribute(attr, options = {})
      key = options.fetch(:key, attr)
      _attributes_keys[attr] = { key: key } if key != attr
      _attributes << key unless _attributes.include?(key)

      ActiveModelSerializers.silence_warnings do
        define_method key do
          object.read_attribute_for_serialization(attr)
        end unless (key != :id && method_defined?(key)) || _fragmented.respond_to?(attr)
      end
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

    def self.root_name
      name.demodulize.underscore.sub(/_serializer$/, '') if name
    end

    def self.serializers_cache
      @serializers_cache ||= ThreadSafe::Cache.new
    end

    def self.digest_caller_file(caller_line)
      serializer_file_path = caller_line[CALLER_FILE]
      serializer_file_contents = IO.read(serializer_file_path)
      Digest::MD5.hexdigest(serializer_file_contents)
    end

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

    attr_accessor :object, :root, :meta, :meta_key, :scope

    def initialize(object, options = {})
      self.object = object
      self.instance_options = options
      self.root = instance_options[:root]
      self.meta = instance_options[:meta]
      self.meta_key = instance_options[:meta_key]
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

    def attributes(options = {})
      attributes =
        if options[:fields]
          self.class._attributes & options[:fields]
        else
          self.class._attributes.dup
        end

      attributes.each_with_object({}) do |name, hash|
        unless self.class._fragmented
          hash[name] = send(name)
        else
          hash[name] = self.class._fragmented.public_send(name)
        end
      end
    end

    # Transforms an inclusion hash into an array of corresponding existing associations,
    # and corresponding inclusion hashes.
    # @param [Hash] includes
    # @return [Array] an array of pairs [association, include_hash] for matching associations
    def expand_includes(includes = {})
      if includes.size == 1 && includes.each_key.first == :*
        associations.map { |assoc| [assoc, includes.each_value.first] }
      elsif includes.size == 1 && includes.each_key.first == :**
        associations.map { |assoc| [assoc, { :** => nil }] }
      else
        expanded_associations = includes.map do |inc|
          association = associations.find { |assoc| assoc.key == inc.first }
          [association, inc.second] if association
        end
        expanded_associations.delete(nil)

        expanded_associations
      end
    end

    private # rubocop:disable Lint/UselessAccessModifier

    ActiveModelSerializers.silence_warnings do
      attr_accessor :instance_options
    end
  end
end
