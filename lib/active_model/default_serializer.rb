module ActiveModel
  # DefaultSerializer
  #
  # Provides a constant interface for all items, particularly
  # for ArraySerializer.
  class DefaultSerializer
    attr_reader :object, :options

    def initialize(object, options={})
      @object, @options = object, options
    end

    def serializable_hash
      @object.as_json(@options)
    end
  end

end