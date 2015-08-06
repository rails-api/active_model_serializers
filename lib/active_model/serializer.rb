require 'thread_safe'

module ActiveModel
  class Serializer
    extend ActiveSupport::Autoload
    require_relative 'serializer/associations'
    require_relative 'serializer/attributes'

    autoload :Configuration
    autoload :ArraySerializer
    autoload :Adapter
    autoload :Lint
    include Configuration
    include Associations
    include Attributes

    class << self
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
      base._urls = []
      serializer_file = File.open(caller.first[/^[^:]+/])
      base._cache_digest = Digest::MD5.hexdigest(serializer_file.read)
      super
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
      name.demodulize.underscore.sub(/_serializer$/, '') if name
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
      @root || object.class.model_name.to_s.downcase
    end

    def id
      object.id if object
    end

    def type
      object.class.model_name.plural
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
