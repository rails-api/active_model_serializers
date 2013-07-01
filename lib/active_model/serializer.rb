module ActiveModel
  class Serializer
    class << self
      def inherited(base)
        base._attributes = {}
      end

      attr_accessor :_attributes

      def attributes(*attrs)
        @_attributes = attrs.map(&:to_s)

        attrs.each do |attr|
          define_method attr do
            object.read_attribute_for_serialization(attr)
          end
        end
      end
    end

    def initialize(object)
      @object = object
    end
    attr_accessor :object

    alias read_attribute_for_serialization send

    def attributes
      self.class._attributes.each_with_object({}) do |name, hash|
        hash[name] = send(name)
      end
    end

    def serializable_hash(options={})
      return nil if object.nil?
      attributes
    end

    def as_json(options={})
      serializable_hash
    end
  end
end
