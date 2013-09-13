module ActiveModel
  # DefaultSerializer
  #
  # Provides a constant interface for all items
  class DefaultSerializer
    attr_reader :object

    def initialize(object, options=nil)
      @object = object
    end

    def serializable_hash(*)
      @object.as_json
    end
    alias serializable_object serializable_hash
  end
end
