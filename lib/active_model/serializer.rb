module ActiveModel
  class Serializer
    class << self
      attr_accessor :_attributes
    end

    def self.inherited(base)
      base._attributes = []
    end

    def self.attributes(*attrs)
      @_attributes.concat attrs

      
      attrs.each do |attr|
        define_method attr do
          object.read_attribute_for_serialization(attr)
        end unless method_defined?(attr)
      end
    end

    if RUBY_VERSION >= '2.0'
      def self.serializer_for(resource)
        if resource.respond_to?(:to_ary)
          ArraySerializer
        else
          begin
            Object.const_get "#{resource.class.name}Serializer"
          rescue NameError
            nil
          end
        end
      end
    else
      def self.serializer_for(resource)
        if resource.respond_to?(:to_ary)
          ArraySerializer
        else
          "#{resource.class.name}Serializer".safe_constantize
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
