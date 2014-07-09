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
    end

    attr_accessor :object

    def initialize(object)
      @object = object
    end
  end
end
