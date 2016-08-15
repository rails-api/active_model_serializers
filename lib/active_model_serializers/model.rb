# ActiveModelSerializers::Model is a convenient
# serializable class to inherit from when making
# serializable non-activerecord objects.
module ActiveModelSerializers
  class Model
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_reader :attributes, :errors

    def initialize(attributes = {})
      @attributes = attributes && attributes.symbolize_keys
      @errors = ActiveModel::Errors.new(self)
      super
    end

    # Defaults to the downcased model name.
    def id
      attributes.fetch(:id) { self.class.name.downcase }
    end

    # Defaults to the downcased model name and updated_at
    def cache_key
      attributes.fetch(:cache_key) { "#{self.class.name.downcase}/#{id}-#{updated_at.strftime('%Y%m%d%H%M%S%9N')}" }
    end

    # Defaults to the time the serializer file was modified.
    def updated_at
      attributes.fetch(:updated_at) { File.mtime(__FILE__) }
    end

    def read_attribute_for_serialization(key)
      if key == :id || key == 'id'
        attributes.fetch(key) { id }
      else
        attributes[key]
      end
    end

    # The following methods are needed to be minimally implemented for ActiveModel::Errors
    # :nocov:
    def self.human_attribute_name(attr, _options = {})
      attr
    end

    def self.lookup_ancestors
      [self]
    end
    # :nocov:
  end
end
