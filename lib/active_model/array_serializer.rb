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

    def serializable_data
      embedded_in_root_associations.merge!(super)
    end

    def embedded_in_root_associations
      hash = {}
      @object.map do |item|
        serializer_class = @each_serializer || Serializer.serializer_for(item) || DefaultSerializer
        associations = serializer_class._associations
        serializer = serializer_class.new(item, @options)
        included_associations = serializer.filter(associations.keys)
        associations.each do |(name, association)|
          if included_associations.include? name
            if association.embed_in_root?
              hash[association.embedded_key] = serializer.serialize association
            end
          end
        end
      end
      hash
    end
  end
end
