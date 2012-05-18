require "active_support/core_ext/class/attribute"
require "active_support/core_ext/module/anonymous"
require "set"

module ActiveModel
  class OrderedSet
    def initialize(array)
      @array = array
      @hash = {}

      array.each do |item|
        @hash[item] = true
      end
    end

    def merge!(other)
      other.each do |item|
        next if @hash.key?(item)

        @hash[item] = true
        @array.push item
      end
    end

    def to_a
      @array
    end
  end

  # Active Model Array Serializer
  #
  # It serializes an array checking if each element that implements
  # the +active_model_serializer+ method.
  class ArraySerializer
    attr_reader :object, :options

    def initialize(object, options={})
      @object, @options = object, options
    end

    def serializable_array
      @object.map do |item|
        if item.respond_to?(:active_model_serializer) && (serializer = item.active_model_serializer)
          serializer.new(item, @options)
        else
          item
        end
      end
    end

    def as_json(*args)
      @options[:hash] = hash = {}
      @options[:unique_values] = {}

      array = serializable_array.map do |item|
        if item.respond_to?(:serializable_hash)
          item.serializable_hash
        else
          item
        end
      end

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
  # it expects to object as arguments, a resource and options. For example,
  # one may do in a controller:
  #
  #     PostSerializer.new(@post, :scope => current_user).to_json
  #
  # The object to be serialized is the +@post+ and the current user is passed
  # in for authorization purposes.
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

            self.options = class_options
          end
        end

        self.options = {}

        def initialize(name, source, options={})
          @name = name
          @source = source
          @options = options
        end

        def option(key, default=nil)
          if @options.key?(key)
            @options[key]
          elsif self.class.options.key?(key)
            self.class.options[key]
          else
            default
          end
        end

        def target_serializer
          option(:serializer)
        end

        def source_serializer
          @source
        end

        def key
          option(:key) || @name
        end

        def root
          option(:root) || plural_key
        end

        def name
          option(:name) || @name
        end

        def associated_object
          option(:value) || source_serializer.send(name)
        end

        def embed_ids?
          option(:embed, source_serializer._embed) == :ids
        end

        def embed_objects?
          option(:embed, source_serializer._embed) == :objects
        end

        def embed_in_root?
          option(:include, source_serializer._root_embed)
        end

      protected

        def find_serializable(object)
          if target_serializer
            target_serializer.new(object, source_serializer.options)
          elsif object.respond_to?(:active_model_serializer) && (ams = object.active_model_serializer)
            ams.new(object, source_serializer.options)
          else
            object
          end
        end
      end

      class HasMany < Config #:nodoc:
        alias plural_key key

        def serialize
          associated_object.map do |item|
            find_serializable(item).serializable_hash
          end
        end
        alias serialize_many serialize

        def serialize_ids
          # Use pluck or select_columns if available
          # return collection.ids if collection.respond_to?(:ids)

          associated_object.map do |item|
            item.read_attribute_for_serialization(:id)
          end
        end
      end

      class HasOne < Config #:nodoc:
        def plural_key
          key.to_s.pluralize.to_sym
        end

        def serialize
          object = associated_object
          object && find_serializable(object).serializable_hash
        end

        def serialize_many
          object = associated_object
          value = object && find_serializable(object).serializable_hash
          value ? [value] : []
        end

        def serialize_ids
          if object = associated_object
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
          attribute attr
        end
      end

      def attribute(attr, options={})
        self._attributes = _attributes.merge(attr => options[:key] || attr)

        unless method_defined?(attr)
          class_eval "def #{attr}() object.read_attribute_for_serialization(:#{attr}) end", __FILE__, __LINE__
        end
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
      #     { :posts => { :has_many => :posts } }
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
          association = association_class.new(attr, self)

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

    attr_reader :object, :options

    def initialize(object, options={})
      @object, @options = object, options
    end

    def url_options
      @options[:url_options]
    end

    # Returns a json representation of the serializable
    # object including the root.
    def as_json(options=nil)
      options ||= {}
      if root = options.fetch(:root, @options.fetch(:root, _root))
        @options[:hash] = hash = {}
        @options[:unique_values] = {}

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
      include_associations!(node) if _embed
      node
    end

    def include_associations!(node)
      _associations.each do |attr, klass|
        opts = { :node => node }

        if options.include?(:include) || options.include?(:exclude)
          opts[:include] = included_association?(attr)
        end

        include! attr, opts
      end
    end

    def included_association?(name)
      if options.key?(:include)
        options[:include].include?(name)
      elsif options.key?(:exclude)
        !options[:exclude].include?(name)
      else
        true
      end
    end

    def include!(name, options={})
      # Make sure that if a special options[:hash] was passed in, we generate
      # a new unique values hash and don't clobber the original. If the hash
      # passed in is the same as the current options hash, use the current
      # unique values.
      #
      # TODO: Should passing in a Hash even be public API here?
      unique_values =
        if hash = options[:hash]
          if @options[:hash] == hash
            @options[:unique_values] ||= {}
          else
            {}
          end
        else
          hash = @options[:hash]
          @options[:unique_values] ||= {}
        end

      node = options[:node]
      value = options[:value]

      association_class =
        if klass = _associations[name]
          klass
        elsif value.respond_to?(:to_ary)
          Associations::HasMany
        else
          Associations::HasOne
        end

      association = association_class.new(name, self, options)

      if association.embed_ids?
        node[association.key] = association.serialize_ids

        if association.embed_in_root?
          merge_association hash, association.root, association.serialize_many, unique_values
        end
      elsif association.embed_objects?
        node[association.key] = association.serialize
      end
    end

    # In some cases, an Array of associations is built by merging the associated
    # content for all of the children. For instance, if a Post has_many comments,
    # which has_many tags, the top-level :tags key will contain the merged list
    # of all tags for all comments of the post.
    #
    # In order to make this efficient, we store a :unique_values hash containing
    # a unique list of all of the objects that are already in the Array. This
    # avoids the need to scan through the Array looking for entries every time
    # we want to merge a new list of values.
    def merge_association(hash, key, value, unique_values)
      if current_value = unique_values[key]
        current_value.merge! value
        hash[key] = current_value.to_a
      elsif value
        hash[key] = value
        unique_values[key] = OrderedSet.new(value)
      end
    end

    # Returns a hash representation of the serializable
    # object attributes.
    def attributes
      hash = {}

      _attributes.each do |name,key|
        hash[key] = read_attribute_for_serialization(name)
      end

      hash
    end

    alias :read_attribute_for_serialization :send
  end
end

class Array
  # Array uses ActiveModel::ArraySerializer.
  def active_model_serializer
    ActiveModel::ArraySerializer
  end
end
