require 'active_model/default_serializer'
require 'active_model/serializable'
require 'active_model/serializer'

module ActiveModel
  class ArraySerializer
    include Serializable

    class << self
      attr_accessor :_root
      alias root  _root=
      alias root= _root=
    end

    def initialize(object, options={})
      @object   = object
      @options  = options
      @root     = options[:root]
      @root     = self.class._root if @root.nil?
      @meta_key = options[:meta_key] || :meta
      @meta     = options[@meta_key]
    end
    attr_accessor :object, :root, :meta_key, :meta

    def serializable_array
      @object.map do |item|
        serializer = @options[:each_serializer] || Serializer.serializer_for(item) || DefaultSerializer
        serializer.new(item).serializable_object(@options.merge(root: nil))
      end
    end
    alias serializable_object serializable_array
  end
end
