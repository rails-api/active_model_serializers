require "active_support/core_ext/class/attribute"

module ActiveModel
  # Active Model Array Serializer
  #
  # It serializes an Array, checking if each element that implements
  # the +active_model_serializer+ method.
  #
  # To disable serialization of root elements:
  #
  #     ActiveModel::ArraySerializer.root = false
  #
  class ArraySerializer
    attr_reader :object, :options

    class_attribute :root

    def initialize(object, options={})
      @object, @options = object, options
    end

    def serializable_array
      @object.map do |item|
        if @options.has_key? :each_serializer
          serializer = @options[:each_serializer]
        elsif item.respond_to?(:active_model_serializer)
          serializer = item.active_model_serializer
        end

        serializable = serializer ? serializer.new(item, @options) : item

        if serializable.respond_to?(:serializable_hash)
          serializable.serializable_hash
        else
          serializable.as_json
        end
      end
    end

    def meta_key
      @options[:meta_key].try(:to_sym) || :meta
    end

    def include_meta(hash)
      hash[meta_key] = @options[:meta] if @options.has_key?(:meta)
    end

    def as_json(*args)
      @options[:hash] = hash = {}
      @options[:unique_values] = {}

      if root = @options[:root]
        hash.merge!(root => serializable_array)
        include_meta hash
        hash
      else
        serializable_array
      end
    end
  end

end
