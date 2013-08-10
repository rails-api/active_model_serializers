require 'active_model/serializer/associations'

module ActiveModel
  class Serializer
    class << self
      def inherited(base)
        base._attributes = []
        base._associations = []
      end

      def serializer_for(resource)
        "#{resource.class.name}Serializer".safe_constantize
      end

      attr_accessor :_root, :_attributes, :_associations

      def root(root)
        @_root = root
      end
      alias root= root

      def root_name
        name.demodulize.underscore.sub(/_serializer$/, '') if name
      end

      def attributes(*attrs)
        @_attributes.concat attrs.map(&:to_s)

        attrs.each do |attr|
          unless method_defined?(attr)
            define_method attr do
              object.read_attribute_for_serialization(attr)
            end
          end
        end
      end

      def has_one(*attrs)
        options = attrs.extract_options!

        attrs.each do |attr|
          attr = attr.to_s

          unless method_defined?(attr)
            define_method attr do
              object.send attr
            end
          end

          @_associations << Association::HasOne.new(attr, options)
        end
      end
    end

    def initialize(object, options={})
      @object   = object
      @scope    = options[:scope]
      @root     = options[:root] || self.class._root
      @root     = self.class.root_name if @root == true
      @meta_key = options[:meta_key] || :meta
      @meta     = options[@meta_key]
    end
    attr_accessor :object, :scope, :root, :meta_key, :meta

    alias read_attribute_for_serialization send

    def attributes
      self.class._attributes.each_with_object({}) do |name, hash|
        hash[name] = send(name)
      end
    end

    def associations
      self.class._associations.each_with_object({}) do |association, hash|
        if association.embed_ids?
          hash[association.key] = serialize_ids association
        elsif association.embed_objects?
          # TODO
          hash
        end
      end
    end

    def serialize_ids(association)
      associated_data = send(association.name)
      if associated_data.respond_to?(:to_ary)
        associated_data.map { |elem| elem.send(association.embed_key) }
      else
        associated_data.send(association.embed_key)
      end
    end

    def serializable_hash(options={})
      return nil if object.nil?
      hash = attributes
      hash.merge! associations
    end

    def as_json(options={})
      if root = options[:root] || self.root
        hash = { root.to_s => serializable_hash }
        hash[meta_key.to_s] = meta if meta
        hash
      else
        serializable_hash
      end
    end
  end
end
