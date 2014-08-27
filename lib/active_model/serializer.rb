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

        if Object.const_defined?(serializer_name)
          Object.const_get(serializer_name)
        end
      end
    end

    attr_accessor :object

    def initialize(object)
      @object = object
    end

    def attributes
      self.class._attributes.dup.each_with_object({}) do |name, hash|
        hash[name] = send(name)
      end
    end
  end
end
