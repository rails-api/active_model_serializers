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
    end

    def self.inherited(base)
      base._attributes = []
      base._associations = {}
    end

    def self.attributes(*attrs)
      @_attributes.concat attrs


      attrs.each do |attr|
        define_method attr do
          object.read_attribute_for_serialization(attr)
        end unless method_defined?(attr)
      end
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

    # Defines an association in the object should be rendered.
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

    def self.serializer_for(resource)
      if resource.respond_to?(:to_ary)
        config.array_serializer
      else
        serializer_name = "#{resource.class.name}Serializer"

        begin
          Object.const_get(serializer_name)
        rescue NameError
          nil
        end
      end
    end

    def self.adapter
      adapter_class = case config.adapter
                      when Symbol
                        class_name = "ActiveModel::Serializer::Adapter::#{config.adapter.to_s.classify}Adapter"
                        if Object.const_defined?(class_name)
                          Object.const_get(class_name)
                        end
                      when Class
                        config.adapter
                      end
      unless adapter_class
        valid_adapters = Adapter.constants.map { |klass| ":#{klass.to_s.sub('Adapter', '').downcase}" }
        raise ArgumentError, "Unknown adapter: #{config.adapter}. Valid adapters are: #{valid_adapters}"
      end

      adapter_class
    end

    attr_accessor :object

    def initialize(object)
      @object = object
    end

    def attributes(options = {})
      self.class._attributes.dup.each_with_object({}) do |name, hash|
        hash[name] = send(name)
      end
    end

    def associations(options = {})
      self.class._associations.dup.each_with_object({}) do |(name, value), hash|
        association = object.send(name)
        serializer_class = ActiveModel::Serializer.serializer_for(association)
        if serializer_class
          serializer = serializer_class.new(association)
          hash[name] = serializer
        else
          hash[name] = association
        end
      end
    end
  end
end
