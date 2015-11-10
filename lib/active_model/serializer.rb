require 'thread_safe'
require 'active_model/serializer/collection_serializer'
require 'active_model/serializer/array_serializer'
require 'active_model/serializer/include_tree'
require 'active_model/serializer/associations'
require 'active_model/serializer/configuration'
require 'active_model/serializer/fieldset'
require 'active_model/serializer/lint'

# ActiveModel::Serializer is an abstract class that is
# reified when subclassed to decorate a resource.
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

    # Hashes contents of file for +_cache_digest+
    def self.digest_caller_file(caller_line)
      serializer_file_path = caller_line[CALLER_FILE]
      serializer_file_contents = IO.read(serializer_file_path)
      Digest::MD5.hexdigest(serializer_file_contents)
    rescue TypeError, Errno::ENOENT
      warn <<-EOF.strip_heredoc
       Cannot digest non-existent file: '#{caller_line}'.
       Please set `::_cache_digest` of the serializer
       if you'd like to cache it.
       EOF
      ''.freeze
    end

    with_options instance_writer: false, instance_reader: false do |serializer|
      class_attribute :_type, instance_reader: true
      class_attribute :_attributes               # @api private : names of attribute methods, @see Serializer#attribute
      self._attributes ||= []
      class_attribute :_attributes_keys          # @api private : maps attribute value to explict key name, @see Serializer#attribute
      self._attributes_keys ||= {}
      class_attribute :_links                    # @api private : links definitions, @see Serializer#link
      self._links ||= {}

      serializer.class_attribute :_cache         # @api private : the cache object
      serializer.class_attribute :_fragmented    # @api private : @see ::fragmented
      serializer.class_attribute :_cache_key     # @api private : when present, is first item in cache_key
      serializer.class_attribute :_cache_only    # @api private : when fragment caching, whitelists cached_attributes. Cannot combine with except
      serializer.class_attribute :_cache_except  # @api private : when fragment caching, blacklists cached_attributes. Cannot combine with only
      serializer.class_attribute :_cache_options # @api private : used by CachedSerializer, passed to _cache.fetch
      #  _cache_options include:
      #    expires_in
      #    compress
      #    force
      #    race_condition_ttl
      #  Passed to ::_cache as
      #    serializer._cache.fetch(cache_key, @klass._cache_options)
      serializer.class_attribute :_cache_digest # @api private : Generated
    end

    # Serializers inherit _attributes and _attributes_keys.
    # Generates a unique digest for each serializer at load.
    def self.inherited(base)
      caller_line = caller.first
      base._attributes = _attributes.dup
      base._attributes_keys = _attributes_keys.dup
      base._links = _links.dup
      base._cache_digest = digest_caller_file(caller_line)
      super
    end

    # @example
    #   class AdminAuthorSerializer < ActiveModel::Serializer
    #     type 'authors'
    def self.type(type)
      self._type = type
    end

    def self.link(name, value = nil, &block)
      _links[name] = block || value
    end

    # @example
    #   class AdminAuthorSerializer < ActiveModel::Serializer
    #     attributes :id, :name, :recent_edits
    def self.attributes(*attrs)
      attrs = attrs.first if attrs.first.class == Array

      attrs.each do |attr|
        attribute(attr)
      end
    end

    # @example
    #   class AdminAuthorSerializer < ActiveModel::Serializer
    #     attributes :id, :recent_edits
    #     attribute :name, key: :title
    #
    #     def recent_edits
    #       object.edits.last(5)
    #     enr
    def self.attribute(attr, options = {})
      key = options.fetch(:key, attr)
      _attributes_keys[attr] = { key: key } if key != attr
      _attributes << key unless _attributes.include?(key)

      ActiveModelSerializers.silence_warnings do
        define_method key do
          object.read_attribute_for_serialization(attr)
        end unless method_defined?(key) || _fragmented.respond_to?(attr)
      end
    end

    # @api private
    # Used by FragmentCache on the CachedSerializer
    #  to call attribute methods on the fragmented cached serializer.
    def self.fragmented(serializer)
      self._fragmented = serializer
    end

    # Enables a serializer to be automatically cached
    #
    # Sets +::_cache+ object to <tt>ActionController::Base.cache_store</tt>
    #   when Rails.configuration.action_controller.perform_caching
    #
    # @params options [Hash] with valid keys:
    #   key            : @see ::_cache_key
    #   only           : @see ::_cache_only
    #   except         : @see ::_cache_except
    #   skip_digest    : does not include digest in cache_key
    #   all else       : @see ::_cache_options
    #
    # @example
    #   class PostSerializer < ActiveModel::Serializer
    #     cache key: 'post', expires_in: 3.hours
    #     attributes :title, :body
    #
    #     has_many :comments
    #   end
    #
    # @todo require less code comments. See
    # https://github.com/rails-api/active_model_serializers/pull/1249#issuecomment-146567837
    def self.cache(options = {})
      self._cache = ActiveModelSerializers.config.cache_store if ActiveModelSerializers.config.perform_caching
      self._cache_key = options.delete(:key)
      self._cache_only = options.delete(:only)
      self._cache_except = options.delete(:except)
      self._cache_options = (options.empty?) ? nil : options
    end

    # @param resource [ActiveRecord::Base, ActiveModelSerializers::Model]
    # @return [ActiveModel::Serializer]
    #   Preferentially returns
    #   1. resource.serializer
    #   2. ArraySerializer when resource is a collection
    #   3. options[:serializer]
    #   4. lookup serializer when resource is a Class
    def self.serializer_for(resource, options = {})
      if resource.respond_to?(:serializer_class)
        resource.serializer_class
      elsif resource.respond_to?(:to_ary)
        config.collection_serializer
      else
        options.fetch(:serializer) { get_serializer_for(resource.class) }
      end
    end

    # @see ActiveModel::Serializer::Adapter.lookup
    def self.adapter
      ActiveModel::Serializer::Adapter.lookup(config.adapter)
    end

    # Used to cache serializer name => serializer class
    # when looked up by Serializer.get_serializer_for.
    def self.serializers_cache
      @serializers_cache ||= ThreadSafe::Cache.new
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
    # Find a serializer from a class and caches the lookup.
    # Preferentially retuns:
    #   1. class name appended with "Serializer"
    #   2. try again with superclass, if present
    #   3. nil
    def self.get_serializer_for(klass)
      serializers_cache.fetch_or_store(klass) do
        # NOTE(beauby): When we drop 1.9.3 support we can lazify the map for perfs.
        serializer_class = serializer_lookup_chain_for(klass).map(&:safe_constantize).find { |x| x && x < ActiveModel::Serializer }

        if serializer_class
          serializer_class
        elsif klass.superclass
          get_serializer_for(klass.superclass)
        end
      end
    end

    attr_accessor :object, :root, :scope

    # `scope_name` is set as :current_user by default in the controller.
    # If the instance does not have a method named `scope_name`, it
    # defines the method so that it calls the +scope+.
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

    # Used by adapter as resource root.
    def json_key
      root || object.class.model_name.to_s.underscore
    end

    # Return the +attributes+ of +object+ as presented
    # by the serializer.
    def attributes(requested_attrs = nil)
      self.class._attributes.each_with_object({}) do |name, hash|
        next unless requested_attrs.nil? || requested_attrs.include?(name)
        if self.class._fragmented
          hash[name] = self.class._fragmented.public_send(name)
        else
          hash[name] = send(name)
        end
      end
    end

    # @api private
    # Used by JsonApi adapter to build resource links.
    def links
      self.class._links
    end

    protected

    attr_accessor :instance_options
  end
end
