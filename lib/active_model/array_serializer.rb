require 'active_model/serializer'

module ActiveModel
  class ArraySerializer
    class << self
      attr_accessor :_root

      def root(root)
        @_root = root
      end
      alias root= root
    end

    def initialize(object, options={})
      @object   = object
      @options  = options
      @root     = options[:root] || self.class._root
      @meta_key = options[:meta_key] || :meta
      @meta     = options[@meta_key]
    end
    attr_accessor :object, :root, :meta_key, :meta

    def serializable_array
      @object.map do |item|
        serializer = @options[:each_serializer] || Serializer.serializer_for(item)
        if serializer
          serializer.new(item).serializable_object(@options.merge(root: nil))
        else
          item.as_json
        end
      end
    end
    alias serializable_object serializable_array

    def as_json(options={})
      if root = options[:root] || self.root
        hash = { root.to_s => serializable_array }
        hash[meta_key.to_s] = meta if meta
        hash
      else
        serializable_array
      end
    end
  end
end
