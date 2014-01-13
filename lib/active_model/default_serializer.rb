require 'active_model/serializable'

module ActiveModel
  # DefaultSerializer
  #
  # Provides a constant interface for all items
  class DefaultSerializer
    include ActiveModel::Serializable

    attr_reader :object, :configuration

    def initialize(object, options = nil)
      @object = object
      @configuration = Serializer::InstanceConfiguration.new nil
    end

    def as_json(options = {})
      @object.as_json
    end
    alias serializable_hash as_json
    alias serializable_object as_json
  end
end
