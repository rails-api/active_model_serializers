require 'active_model/default_serializer'
require 'active_model/serializable'
require 'active_model/serializer'

module ActiveModel
  class HashSerializer
    include Serializable

    class << self
      attr_accessor :_root
      alias root  _root=
      alias root= _root=
    end

    def initialize(object, options={})
      @object          = object
      @root            = options[:root]
      @root            = self.class._root if @root.nil?
      @root            = options[:resource_name] if @root.nil?
      @meta_key        = options[:meta_key] || :meta
      @meta            = options[@meta_key]
      @value_serializer = options[:value_serializer]
      @options         = options.merge(root: nil)
    end
    attr_accessor :object, :root, :meta_key, :meta

    def serializable_hash
      @object.inject({}) do |output, key_value_pair|
        key = key_value_pair.first
        item = key_value_pair.last
        serializer = @value_serializer || Serializer.serializer_for(item) || DefaultSerializer
        new_item = serializer.new(item, @options).serializable_object
        output.merge(key => new_item)
      end
    end
    alias serializable_object serializable_hash
  end
end
