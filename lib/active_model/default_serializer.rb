require 'active_model/serializable'

module ActiveModel
  # DefaultSerializer
  #
  # Provides a constant interface for all items
  class DefaultSerializer
    include ActiveModel::Serializable

    attr_reader :object

    def initialize(object, options=nil)
      @object = object
    end

    def as_json(options={})
      @object.as_json
    end
    alias serializable_hash as_json
    alias serializable_object as_json

    def as_xml(options={})
      @object.as_xml
    end
  end
end
