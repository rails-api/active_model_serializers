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
      @object          = object
      @root            = options.fetch(:root, self.class._root)
      @meta_key        = options[:meta_key] || :meta
      @meta            = options[@meta_key]
      @each_serializer = options[:each_serializer]
      @options         = options.merge(root: nil)
    end
    attr_accessor :object, :root, :meta_key, :meta

    def json_key
      if root.nil?
        @options[:resource_name]
      else
        root
      end
    end

    def serializable_array
      @object.map do |item|
        serializer = @each_serializer || Serializer.serializer_for(item) || DefaultSerializer
        serializer.new(item, @options).serializable_object
      end
    end
    alias_method :serializable_object, :serializable_array
  end
end
