# ActiveModelSerializers::Model is a convenient
# serializable class to inherit from when making
# serializable non-activerecord objects.
module ActiveModelSerializers
  class Model
    include ActiveModelSerializers::ModelMixin

    attr_reader :attributes

    def initialize(attrs = {})
      @attributes = attrs && attrs.symbolize_keys

      @attributes.each_pair do |key, value|
        if respond_to?("#{key}=", value)
          send("#{key}=", value)
        end
      end
    end

    def cache_key
      attributes.fetch(:cache_key) { "#{self.class.name.downcase}/#{id}-#{updated_at.strftime('%Y%m%d%H%M%S%9N')}" }
    end

    # Defaults to the time the serializer file was modified.
    def updated_at
      attributes.fetch(:updated_at) { File.mtime(__FILE__) }
    end

    def id
      attributes.fetch(:id) { self.class.name.downcase }
    end
  end
end
