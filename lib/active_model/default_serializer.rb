require 'active_model/serializable'

module ActiveModel
  # DefaultSerializer
  #
  # Provides a constant interface for all items
  class DefaultSerializer
    include ActiveModel::Serializable

    attr_reader :object

    def initialize(object, options={})
      @object = object
      @wrap_in_array = options[:_wrap_in_array]
    end

    def as_json(options={})
      return @wrap_in_array ? [] : nil if @object.nil?
      hash = @object.as_json
      @wrap_in_array ? [hash] : hash
    end
    alias serializable_hash as_json
    alias serializable_object as_json
  end
end
