module ActiveModel
  module Deserializer

    def deserialize(resource)
      # Defining the Resource and Attributes
      @resource = resource
      @model    = resource.to_s.camelize.constantize
      @params   = params
      self
    end

    def object
      # Return the existing instance of the Resource or initialize a new one
      @model.find_or_initialize_by(_params)
    end

    private

    def _params
      # Automatically permitting the attributes that should be deserialized
      @serializer = get_serializer_for(@model)
      @params.require(@resource).permit(@serializer._deserialize)
    end

    # (WIP)Replicated code just for testing for now
    def serializers_cache
      @serializers_cache ||= ThreadSafe::Cache.new
    end

    def get_serializer_for(klass)
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
