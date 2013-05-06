require "active_support/core_ext/class/attribute"
require "active_support/core_ext/module/anonymous"
require 'active_support/dependencies'
require 'active_support/descendants_tracker'

module ActiveModel
  # Active Model Serializer
  #
  # Provides a basic serializer implementation that allows you to easily
  # control how a given object is going to be serialized. On initialization,
  # it expects two objects as arguments, a resource and options. For example,
  # one may do in a controller:
  #
  #     PostSerializer.new(@post, :scope => current_user).to_json
  #
  # The object to be serialized is the +@post+ and the current user is passed
  # in for authorization purposes.
  #
  # We use the scope to check if a given attribute should be serialized or not.
  # For example, some attributes may only be returned if +current_user+ is the
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
    extend ActiveSupport::DescendantsTracker

    INCLUDE_METHODS = {}
    INSTRUMENT = { :serialize => :"serialize.serializer", :associations => :"associations.serializer" }

    class IncludeError < StandardError
      attr_reader :source, :association

      def initialize(source, association)
        @source, @association = source, association
      end

      def to_s
        "Cannot serialize #{association} when #{source} does not have a root!"
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

    class_attribute :cache
    class_attribute :perform_caching

    class << self
      # set perform caching like root
      def cached(value = true)
        self.perform_caching = value
      end

      # Define attributes to be used in the serialization.
      def attributes(*attrs)

        self._attributes = _attributes.dup

        attrs.each do |attr|
          if Hash === attr
            attr.each {|attr_real, key| attribute attr_real, :key => key }
          else
            attribute attr
          end
        end
      end

      def attribute(attr, options={})
        self._attributes = _attributes.merge(attr.is_a?(Hash) ? attr : {attr => options[:key] || attr.to_s.gsub(/\?$/, '').to_sym})

        attr = attr.keys[0] if attr.is_a? Hash

        unless method_defined?(attr)
          define_method attr do
            object.read_attribute_for_serialization(attr.to_sym)
          end
        end

        define_include_method attr

        # protect inheritance chains and open classes
        # if a serializer inherits from another OR
        #  attributes are added later in a classes lifecycle
        # poison the cache
        define_method :_fast_attributes do
          raise NameError
        end

      end

      def associate(klass, attrs) #:nodoc:
        options = attrs.extract_options!
        self._associations = _associations.dup

        attrs.each do |attr|
          unless method_defined?(attr)
            define_method attr do
              object.send attr
            end
          end

          define_include_method attr

          self._associations[attr] = klass.refine(attr, options)
        end
      end

      def define_include_method(name)
        method = "include_#{name}?".to_sym

        INCLUDE_METHODS[name] = method

        unless method_defined?(method)
          define_method method do
            true
          end
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

        attrs = {}
        _attributes.each do |name, key|
          if column = columns[name.to_s]
            attrs[key] = column.type
          else
            # Computed attribute (method on serializer or model). We cannot
            # infer the type, so we put nil, unless specified in the attribute declaration
            if name != key
              attrs[name] = key
            else
              attrs[key] = nil
            end
          end
        end

        associations = {}
        _associations.each do |attr, association_class|
          association = association_class.new(attr, self)

          if model_association = klass.reflect_on_association(association.name)
            # Real association.
            associations[association.key] = { model_association.macro => model_association.name }
          else
            # Computed association. We could infer has_many vs. has_one from
            # the association class, but that would make it different from
            # real associations, which read has_one vs. belongs_to from the
            # model.
            associations[association.key] = nil
          end
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
      alias_method :root=, :root

      # Used internally to create a new serializer object based on controller
      # settings and options for a given resource. These settings are typically
      # set during the request lifecycle or by the controller class, and should
      # not be manually defined for this method.
      def build_json(controller, resource, options)
        default_options = controller.send(:default_serializer_options) || {}
        options = default_options.merge(options || {})

        serializer = options.delete(:serializer) ||
          (resource.respond_to?(:active_model_serializer) &&
           resource.active_model_serializer)

        return serializer unless serializer

        if resource.respond_to?(:to_ary)
          unless serializer <= ActiveModel::ArraySerializer
            raise ArgumentError.new("#{serializer.name} is not an ArraySerializer. " +
                                    "You may want to use the :each_serializer option instead.")
          end

          if options[:root] != false && serializer.root != false
            # the serializer for an Array is ActiveModel::ArraySerializer
            options[:root] ||= serializer.root || controller.controller_name
          end
        end

        options[:scope] = controller.serialization_scope unless options.has_key?(:scope)
        options[:scope_name] = controller._serialization_scope
        options[:url_options] = controller.url_options

        serializer.new(resource, options)
      end
    end

    attr_reader :object, :options

    def initialize(object, options={})
      @object, @options = object, options

      scope_name = @options[:scope_name]
      if scope_name && !respond_to?(scope_name)
        self.class.class_eval do
          define_method scope_name, lambda { scope }
        end
      end
    end

    def root_name
      return false if self._root == false

      class_name = self.class.name.demodulize.underscore.sub(/_serializer$/, '').to_sym unless self.class.name.blank?

      if self._root == true
        class_name
      else
        self._root || class_name
      end
    end

    def url_options
      @options[:url_options] || {}
    end

    def meta_key
      @options[:meta_key].try(:to_sym) || :meta
    end

    def include_meta(hash)
      hash[meta_key] = @options[:meta] if @options.has_key?(:meta)
    end

    def to_json(*args)
      if perform_caching?
        cache.fetch expand_cache_key([self.class.to_s.underscore, cache_key, 'to-json']) do
          super
        end
      else
        super
      end
    end

    # Returns a json representation of the serializable
    # object including the root.
    def as_json(options={})
      if root = options.fetch(:root, @options.fetch(:root, root_name))
        @options[:hash] = hash = {}
        @options[:unique_values] = {}

        hash.merge!(root => serializable_hash)
        include_meta hash
        hash
      else
        serializable_hash
      end
    end

    # Returns a hash representation of the serializable
    # object without the root.
    def serializable_hash
      if perform_caching?
        cache.fetch expand_cache_key([self.class.to_s.underscore, cache_key, 'serializable-hash']) do
          _serializable_hash
        end
      else
        _serializable_hash
      end
    end

    def include_associations!
      _associations.each_key do |name|
        include!(name) if include?(name)
      end
    end

    def include?(name)
      return false if @options.key?(:only) && !Array(@options[:only]).include?(name)
      return false if @options.key?(:except) && Array(@options[:except]).include?(name)
      send INCLUDE_METHODS[name]
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

      node = options[:node] ||= @node
      value = options[:value]

      if options[:include] == nil
        if @options.key?(:include)
          options[:include] = @options[:include].include?(name)
        elsif @options.include?(:exclude)
          options[:include] = !@options[:exclude].include?(name)
        end
      end

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

        if association.embed_in_root? && hash.nil?
          raise IncludeError.new(self.class, association.name)
        elsif association.embed_in_root? && association.embeddable?
          merge_association hash, association.root, association.serializables, unique_values
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
    def merge_association(hash, key, serializables, unique_values)
      already_serialized = (unique_values[key] ||= {})
      serializable_hashes = (hash[key] ||= [])

      serializables.each do |serializable|
        unless already_serialized.include? serializable.object
          already_serialized[serializable.object] = true
          serializable_hashes << serializable.serializable_hash
        end
      end
    end

    # Returns a hash representation of the serializable
    # object attributes.
    def attributes
      _fast_attributes
      rescue NameError
        method = "def _fast_attributes\n"

        method << "  h = {}\n"

        _attributes.each do |name,key|
          method << "  h[:\"#{key}\"] = read_attribute_for_serialization(:\"#{name}\") if include?(:\"#{name}\")\n"
        end
        method << "  h\nend"

        self.class.class_eval method
        _fast_attributes
    end

    # Returns options[:scope]
    def scope
      @options[:scope]
    end

    alias :read_attribute_for_serialization :send

    def _serializable_hash
      return nil if @object.nil?
      @node = attributes
      include_associations! if _embed
      @node
    end

    def perform_caching?
      perform_caching && cache && respond_to?(:cache_key)
    end

    def expand_cache_key(*args)
      ActiveSupport::Cache.expand_cache_key(args)
    end

    # Use ActiveSupport::Notifications to send events to external systems.
    # The event name is: name.class_name.serializer
    def instrument(name, payload = {}, &block)
      event_name = INSTRUMENT[name]
      ActiveSupport::Notifications.instrument(event_name, payload, &block)
    end
  end

  # DefaultSerializer
  #
  # Provides a constant interface for all items, particularly
  # for ArraySerializer.
  class DefaultSerializer
    attr_reader :object, :options

    def initialize(object, options={})
      @object, @options = object, options
    end

    def serializable_hash
      @object.as_json(@options)
    end
  end
end
