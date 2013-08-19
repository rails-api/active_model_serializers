module ActiveModel
  class ArraySerializer
    def initialize(object, options={})
      @object  = object
      @options = options
    end

    def serializable_array
      @object.map do |item|
        if serializer = Serializer.serializer_for(item)
          serializer.new(item).serializable_object(@options.merge(root: nil))
        else
          item.as_json
        end
      end
    end
    alias serializable_object serializable_array
  end
end
