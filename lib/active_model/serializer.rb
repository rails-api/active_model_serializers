module ActiveModel
  class Serializer
    extend ActiveSupport::Autoload
    autoload :Configuration
    autoload :ArraySerializer
    autoload :Adapter
    include Configuration

    class << self
      attr_accessor :_attributes
      attr_accessor :_associations
      attr_accessor :_urls
    end

    def self.inherited(base)
      base._attributes = []
      base._associations = {}
      base._urls = []
    end

    def self.attributes(*attrs)
      @_attributes.concat attrs

      attrs.each do |attr|
        define_method attr do
          object.read_attribute_for_serialization(attr)
        end unless method_defined?(attr)
      end
    end

    def self.attribute(attr, options = {})
      key = options.fetch(:key, attr)
      @_attributes.concat [key]
      define_method key do
        object.read_attribute_for_serialization(attr)
      end unless method_defined?(key)
    end

    # Defines an association in the object that should be rendered.
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

    def self.associate(type, attrs) #:nodoc:
      options = attrs.extract_options!
      self._associations = _associations.dup

      attrs.each do |attr|
        unless method_defined?(attr)
          define_method attr do
            object.send attr
          end
        end

        self._associations[attr] = {type: type, options: options}
      end
    end

    def self.url(attr)
      @_urls.push attr
    end

    def self.urls(*attrs)
      @_urls.concat attrs
    end

    def self.serializer_for(resource)
      if resource.respond_to?(:to_ary)
        config.array_serializer
      else
        get_serializer_for(resource.class)
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

    attr_accessor :object, :root

    def initialize(object, options = {})
      @object = object
      @root   = options[:root] || (self.class._root ? self.class.root_name : false)
    end

    def json_key
      if root == true || root.nil?
        self.class.root_name
      else
        root
      end
    end

    def attributes(options = {})
      self.class._attributes.dup.each_with_object({}) do |name, hash|
        hash[name] = send(name)
      end
    end

    def each_association(&block)
      self.class._associations.dup.each do |name, options|
        association = object.send(name)
        serializer_class = ActiveModel::Serializer.serializer_for(association)
        serializer = serializer_class.new(association, options[:options]) if serializer_class

        if block_given?
          block.call(name, serializer, options[:options])
        end
      end
    end

    private

    def self.get_serializer_for(klass)
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
