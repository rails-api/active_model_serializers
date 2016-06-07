require 'thread_safe'
require 'jsonapi/include_directive'
require 'active_model/serializer/collection_serializer'
require 'active_model/serializer/array_serializer'
require 'active_model/serializer/error_serializer'
require 'active_model/serializer/errors_serializer'
require 'active_model/serializer/associations'
require 'active_model/serializer/attributes'
require 'active_model/serializer/caching'
require 'active_model/serializer/configuration'
require 'active_model/serializer/fieldset'
require 'active_model/serializer/lint'
require 'active_model/serializer/links'
require 'active_model/serializer/meta'
require 'active_model/serializer/type'

# ActiveModel::Serializer is an abstract class that is
# reified when subclassed to decorate a resource.
module ActiveModel
  class Serializer
    # @see #serializable_hash for more details on these valid keys.
    SERIALIZABLE_HASH_VALID_KEYS = [:only, :except, :methods, :include, :root].freeze
    extend ActiveSupport::Autoload
    autoload :Adapter
    autoload :Null
    include Configuration
    include Associations
    include Attributes
    include Caching
    include Links
    include Meta
    include Type

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

    # @see ActiveModelSerializers::Adapter.lookup
    # Deprecated
    def self.adapter
      ActiveModelSerializers::Adapter.lookup(config.adapter)
    end
    class << self
      extend ActiveModelSerializers::Deprecate
      deprecate :adapter, 'ActiveModelSerializers::Adapter.configured_adapter'
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

    # Used to cache serializer name => serializer class
    # when looked up by Serializer.get_serializer_for.
    def self.serializers_cache
      @serializers_cache ||= ThreadSafe::Cache.new
    end

    # @api private
    # Find a serializer from a class and caches the lookup.
    # Preferentially returns:
    #   1. class name appended with "Serializer"
    #   2. try again with superclass, if present
    #   3. nil
    def self.get_serializer_for(klass)
      return nil unless config.serializer_lookup_enabled
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

    # @api private
    def self.include_directive_from_options(options)
      if options[:include_directive]
        options[:include_directive]
      elsif options[:include]
        JSONAPI::IncludeDirective.new(options[:include], allow_wildcard: true)
      else
        ActiveModelSerializers.default_include_directive
      end
    end

    # @api private
    def self.serialization_adapter_instance
      @serialization_adapter_instance ||= ActiveModelSerializers::Adapter::Attributes
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
        define_singleton_method scope_name, lambda { scope }
      end
    end

    def success?
      true
    end

    # @return [Hash] containing the attributes and first level
    # associations, similar to how ActiveModel::Serializers::JSON is used
    # in ActiveRecord::Base.
    #
    # TODO: Include <tt>ActiveModel::Serializers::JSON</tt>.
    # So that the below is true:
    #   @param options [nil, Hash] The same valid options passed to `serializable_hash`
    #      (:only, :except, :methods, and :include).
    #
    #     See
    #     https://github.com/rails/rails/blob/v5.0.0.beta2/activemodel/lib/active_model/serializers/json.rb#L17-L101
    #     https://github.com/rails/rails/blob/v5.0.0.beta2/activemodel/lib/active_model/serialization.rb#L85-L123
    #     https://github.com/rails/rails/blob/v5.0.0.beta2/activerecord/lib/active_record/serialization.rb#L11-L17
    #     https://github.com/rails/rails/blob/v5.0.0.beta2/activesupport/lib/active_support/core_ext/object/json.rb#L147-L162
    #
    #   @example
    #     # The :only and :except options can be used to limit the attributes included, and work
    #     # similar to the attributes method.
    #     serializer.as_json(only: [:id, :name])
    #     serializer.as_json(except: [:id, :created_at, :age])
    #
    #     # To include the result of some method calls on the model use :methods:
    #     serializer.as_json(methods: :permalink)
    #
    #     # To include associations use :include:
    #     serializer.as_json(include: :posts)
    #     # Second level and higher order associations work as well:
    #     serializer.as_json(include: { posts: { include: { comments: { only: :body } }, only: :title } })
    def serializable_hash(adapter_options = nil, options = {}, adapter_instance = self.class.serialization_adapter_instance)
      adapter_options ||= {}
      options[:include_directive] ||= ActiveModel::Serializer.include_directive_from_options(adapter_options)
      cached_attributes = adapter_options[:cached_attributes] ||= {}
      resource = fetch_attributes(options[:fields], cached_attributes, adapter_instance)
      relationships = resource_relationships(adapter_options, options, adapter_instance)
      resource.merge(relationships)
    end
    alias to_hash serializable_hash
    alias to_h serializable_hash

    # @see #serializable_hash
    # TODO: When moving attributes adapter logic here, @see #serializable_hash
    # So that the below is true:
    #   @param options [nil, Hash] The same valid options passed to `as_json`
    #      (:root, :only, :except, :methods, and :include).
    #   The default for `root` is nil.
    #   The default value for include_root is false. You can change it to true if the given
    #   JSON string includes a single root node.
    def as_json(adapter_opts = nil)
      serializable_hash(adapter_opts)
    end

    # Used by adapter as resource root.
    def json_key
      root || _type || object.class.model_name.to_s.underscore
    end

    def read_attribute_for_serialization(attr)
      if respond_to?(attr)
        send(attr)
      else
        object.read_attribute_for_serialization(attr)
      end
    end

    # @api private
    def resource_relationships(adapter_options, options, adapter_instance)
      relationships = {}
      include_directive = options.fetch(:include_directive)
      associations(include_directive).each do |association|
        adapter_opts = adapter_options.merge(include_directive: include_directive[association.key])
        relationships[association.key] ||= relationship_value_for(association, adapter_opts, adapter_instance)
      end

      relationships
    end

    # @api private
    def relationship_value_for(association, adapter_options, adapter_instance)
      return association.options[:virtual_value] if association.options[:virtual_value]
      association_serializer = association.serializer
      association_object = association_serializer && association_serializer.object
      return unless association_object

      relationship_value = association_serializer.serializable_hash(adapter_options, {}, adapter_instance)

      if association.options[:polymorphic] && relationship_value
        polymorphic_type = association_object.class.name.underscore
        relationship_value = { type: polymorphic_type, polymorphic_type.to_sym => relationship_value }
      end

      relationship_value
    end

    protected

    attr_accessor :instance_options
  end
end
