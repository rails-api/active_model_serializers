require 'active_model/serializable'
require 'active_model/serializer/caching'
require "active_support/core_ext/class/attribute"
require 'active_support/dependencies'
require 'active_support/descendants_tracker'

module ActiveModel
  # Active Model Array Serializer
  #
  # Serializes an Array, checking if each element implements
  # the +active_model_serializer+ method.
  #
  # To disable serialization of root elements:
  #
  #     ActiveModel::ArraySerializer.root = false
  #
  class ArraySerializer
    extend ActiveSupport::DescendantsTracker

    include ActiveModel::Serializable
    include ActiveModel::Serializer::Caching

    attr_reader :object, :options

    class_attribute :root

    class_attribute :cache
    class_attribute :perform_caching

    class << self
      # set perform caching like root
      def cached(value = true)
        self.perform_caching = value
      end
    end

    def initialize(object, options={})
      @object  = object
      @options = options
    end

    def url_options
      @options[:url_options] || {}
    end

    def serialize_object
      serializable_array
    end

    def serializable_array
      object.map do |item|
        if options.has_key? :each_serializer
          serializer = options[:each_serializer]
        elsif item.respond_to?(:active_model_serializer)
          serializer = item.active_model_serializer
        end
        serializer ||= DefaultSerializer

        serializable = serializer.new(item, options.merge(root: nil))

        if serializable.respond_to?(:serializable_hash)
          serializable.serializable_hash
        else
          serializable.as_json
        end
      end
    end
  end
end
