module ActiveModel
  class Serializer
    class << self
      def inherited(base)
        base._attributes = {}
      end

      attr_accessor :_root, :_attributes

      def root(root)
        @_root = root
      end
      alias root= root

      def root_name
        name.demodulize.underscore.sub(/_serializer$/, '') if name
      end

      def attributes(*attrs)
        @_attributes = attrs.map(&:to_s)

        attrs.each do |attr|
          define_method attr do
            object.read_attribute_for_serialization(attr)
          end
        end
      end
    end

    def initialize(object, options={})
      @object = object
      @root   = options[:root] || self.class._root
      @root   = self.class.root_name if @root == true
      @scope  = options[:scope]
    end
    attr_accessor :object, :root, :scope

    alias read_attribute_for_serialization send

    def attributes
      self.class._attributes.each_with_object({}) do |name, hash|
        hash[name] = send(name)
      end
    end

    def serializable_hash(options={})
      return nil if object.nil?
      attributes
    end

    def as_json(options={})
      if root = options[:root] || self.root
        { root.to_s => serializable_hash }
      else
        serializable_hash
      end
    end
  end
end
