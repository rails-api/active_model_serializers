require "active_support/core_ext/class/attribute"
require "active_support/core_ext/module/anonymous"

module ActiveModel
  # Active Model Array Serializer
  #
  # It serializes an array checking if each element that implements
  # the +active_model_serializer+ method passing down the current scope.
  class ArraySerializer
    attr_reader :object, :scope

    def initialize(object, scope, options={})
      @object, @scope, @options = object, scope, options
    end

    def serializable_array
      @object.map do |item|
        if item.respond_to?(:active_model_serializer) && (serializer = item.active_model_serializer)
          serializer.new(item, scope, @options)
        else
          item
        end
      end
    end

    def as_json(*args)
      @options[:hash] = hash = {}

      array = serializable_array.map(&:serializable_hash)

      if root = @options[:root]
        hash.merge!(root => array)
      else
        array
      end
    end
  end

  # Active Model Serializer
  #
  # Provides a basic serializer implementation that allows you to easily
  # control how a given object is going to be serialized. On initialization,
  # it expects to object as arguments, a resource and a scope. For example,
  # one may do in a controller:
  #
  #     PostSerializer.new(@post, current_user).to_json
  #
  # The object to be serialized is the +@post+ and the scope is +current_user+.
  #
  # We use the scope to check if a given attribute should be serialized or not.
  # For example, some attributes maybe only be returned if +current_user+ is the
  # author of the post:
  #
  #     class PostSerializer < ActiveModel::Serializer
  #       attributes :title, :body
  #       has_many :comments
  #
  #       private
  #
  #       def attributes
  #         hash = super
  #         hash.merge!(:email => post.email) if author?
  #         hash
  #       end
  #
  #       def author?
  #         post.author == scope
  #       end
  #     end
  #
  class Serializer
    module Associations #:nodoc:
      class Config #:nodoc:
        class_attribute :association_name
        class_attribute :options

        def self.refine(name, class_options)
          current_class = self

          Class.new(self) do
            singleton_class.class_eval do
              define_method(:to_s) do
                "(subclass of #{current_class.name})"
              end

              alias inspect to_s
            end

            self.association_name = name
            self.options = class_options

            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def initialize(options={})
                super(self.class.association_name, options)
              end
            RUBY
          end
        end

        self.options = {}

        def initialize(name=nil, options={})
          @name = name || self.class.association_name
          @options = options
        end

        def option(key)
          if @options.key?(key)
            @options[key]
          elsif self.class.options[key]
            self.class.options[key]
          end
        end

        def target_serializer
          option(:serializer)
        end

        def key
          option(:key) || @name
        end

        def name
          option(:name) || @name
        end

        def associated_object(serializer)
          option(:value) || serializer.send(name)
        end

      protected

        def find_serializable(object, scope, serializer)
          if target_serializer
            target_serializer.new(object, scope, serializer.options)
          elsif object.respond_to?(:active_model_serializer) && (ams = object.active_model_serializer)
            ams.new(object, scope, serializer.options)
          else
            object
          end
        end
      end

      class HasMany < Config #:nodoc:
        alias plural_key key

        def serialize(serializer, scope)
          associated_object(serializer).map do |item|
            find_serializable(item, scope, serializer).serializable_hash
          end
        end
        alias serialize_many serialize

        def serialize_ids(serializer, scope)
          # Use pluck or select_columns if available
          # return collection.ids if collection.respond_to?(:ids)

          associated_object(serializer).map do |item|
            item.read_attribute_for_serialization(:id)
          end
        end
      end

      class HasOne < Config #:nodoc:
        def plural_key
          key.to_s.pluralize.to_sym
        end

        def serialize(serializer, scope)
          object = associated_object(serializer)
          object && find_serializable(object, scope, serializer).serializable_hash
        end

        def serialize_many(serializer, scope)
          object = associated_object(serializer)
          value = object && find_serializable(object, scope, serializer).serializable_hash
          value ? [value] : []
        end

        def serialize_ids(serializer, scope)
          if object = associated_object(serializer)
            object.read_attribute_for_serialization(:id)
          else
            nil
          end
        end
      end
    end

    class_attribute :_attributes
    self._attributes = {}

    class_attribute :_associations
    self._associations = {}

    class_attribute :_root
    class_attribute :_embed
    self._embed = :objects
    class_attribute :_root_embed

    class << self
      # Define attributes to be used in the serialization.
      def attributes(*attrs)
        self._attributes = _attributes.dup

        attrs.each do |attr|
          self._attributes[attr] = attr
        end
      end

      def attribute(attr, options={})
        self._attributes = _attributes.merge(attr => options[:key] || attr)
      end

      def associate(klass, attrs) #:nodoc:
        options = attrs.extract_options!
        self._associations = _associations.dup

        attrs.each do |attr|
          unless method_defined?(attr)
            class_eval "def #{attr}() object.#{attr} end", __FILE__, __LINE__
          end

          self._associations[attr] = klass.refine(attr, options)
        end
      end

      # Defines an association in the object should be rendered.
      #
      # The serializer object should implement the association name
      # as a method which should return an array when invoked. If a method
      # with the association name does not exist, the association name is
      # dispatched to the serialized object.
      def has_many(*attrs)
        associate(Associations::HasMany, attrs)
      end

      # Defines an association in the object should be rendered.
      #
      # The serializer object should implement the association name
      # as a method which should return an object when invoked. If a method
      # with the association name does not exist, the association name is
      # dispatched to the serialized object.
      def has_one(*attrs)
        associate(Associations::HasOne, attrs)
      end

      # Return a schema hash for the current serializer. This information
      # can be used to generate clients for the serialized output.
      #
      # The schema hash has two keys: +attributes+ and +associations+.
      #
      # The +attributes+ hash looks like this:
      #
      #     { :name => :string, :age => :integer }
      #
      # The +associations+ hash looks like this:
           { :posts => { :has_many => :posts } }
      #
      # If :key is used:
      #
      #     class PostsSerializer < ActiveModel::Serializer
      #       has_many :posts, :key => :my_posts
      #     end
      #
      # the hash looks like this:
      #
      #     { :my_posts => { :has_many => :posts }
      #
      # This information is extracted from the serializer's model class,
      # which is provided by +SerializerClass.model_class+.
      #
      # The schema method uses the +columns_hash+ and +reflect_on_association+
      # methods, provided by default by ActiveRecord. You can implement these
      # methods on your custom models if you want the serializer's schema method
      # to work.
      #
      # TODO: This is currently coupled to Active Record. We need to
      # figure out a way to decouple those two.
      def schema
        klass = model_class
        columns = klass.columns_hash

        attrs = _attributes.inject({}) do |hash, (name,key)|
          column = columns[name.to_s]
          hash.merge key => column.type
        end

        associations = _associations.inject({}) do |hash, (attr,association_class)|
          association = association_class.new

          model_association = klass.reflect_on_association(association.name)
          hash.merge association.key => { model_association.macro => model_association.name }
        end

        { :attributes => attrs, :associations => associations }
      end

      # The model class associated with this serializer.
      def model_class
        name.sub(/Serializer$/, '').constantize
      end

      # Define how associations should be embedded.
      #
      #   embed :objects               # Embed associations as full objects
      #   embed :ids                   # Embed only the association ids
      #   embed :ids, :include => true # Embed the association ids and include objects in the root
      #
      def embed(type, options={})
        self._embed = type
        self._root_embed = true if options[:include]
      end

      # Defines the root used on serialization. If false, disables the root.
      def root(name)
        self._root = name
      end

      def inherited(klass) #:nodoc:
        return if klass.anonymous?
        name = klass.name.demodulize.underscore.sub(/_serializer$/, '')

        klass.class_eval do
          alias_method name.to_sym, :object
          root name.to_sym unless self._root == false
        end
      end
    end

    attr_reader :object, :scope, :options

    def initialize(object, scope, options={})
      @object, @scope, @options = object, scope, options
    end

    # Returns a json representation of the serializable
    # object including the root.
    def as_json(options=nil)
      options ||= {}
      if root = options.fetch(:root, @options.fetch(:root, _root))
        @options[:hash] = hash = {}
        hash.merge!(root => serializable_hash)
        hash
      else
        serializable_hash
      end
    end

    # Returns a hash representation of the serializable
    # object without the root.
    def serializable_hash
      node = attributes

      if _embed
        _associations.each do |attr, klass|
          include! attr, :node => node
        end
      end

      node
    end

    def include!(name, options={})
      embed = options[:embed] || _embed
      root_embed = options[:include] || _root_embed
      hash = options[:hash] || @options[:hash]
      node = options[:node]
      value = options[:value]
      serializer = options[:serializer]
      scope = options[:scope] || self.scope

      association_class = _associations[name]
      association = association_class.new(options) if association_class

      association ||= if value.respond_to?(:to_ary)
        Associations::HasMany.new(name, options)
      else
        Associations::HasOne.new(name, options)
      end

      if embed == :ids
        node[association.key] = association.serialize_ids(self, scope)

        if root_embed
          merge_association hash, association.plural_key, association.serialize_many(self, scope)
        end
      elsif embed == :objects
        node[association.key] = association.serialize(self, scope)
      end
    end

    # Merge associations for embed case by always adding
    # root associations to the given hash.
    def merge_associations(hash, associations)
      associations.each do |key, value|
        merge_association(hash, key, value)
      end
    end

    def merge_association(hash, key, value)
      if hash[key]
        hash[key] |= value
      elsif value
        hash[key] = value
      end
    end

    # Returns a hash representation of the serializable
    # object associations.
    def associations
      hash = {}

      _associations.each do |attr, association_class|
        association = association_class.new
        hash[association.key] = association.serialize(self, scope)
      end

      hash
    end

    def plural_associations
      hash = {}

      _associations.each do |attr, association_class|
        association = association_class.new
        hash[association.plural_key] = association.serialize_many(self, scope)
      end

      hash
    end

    # Returns a hash representation of the serializable
    # object associations ids.
    def association_ids
      hash = {}

      _associations.each do |attr, association_class|
        association = association_class.new
        hash[association.key] = association.serialize_ids(self, scope)
      end

      hash
    end

    # Returns a hash representation of the serializable
    # object attributes.
    def attributes
      hash = {}

      _attributes.each do |name,key|
        hash[key] = @object.read_attribute_for_serialization(name)
      end

      hash
    end
  end
end

class Array
  # Array uses ActiveModel::ArraySerializer.
  def active_model_serializer
    ActiveModel::ArraySerializer
  end
end
