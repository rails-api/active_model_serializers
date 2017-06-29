# frozen_string_literal: true

require "json"
require "ams/inflector"
module AMS
  # Lightweight mapping of a model to a JSON API resource object
  # with attributes and relationships
  #
  # The fundamental building block of AMS is the Serializer.
  # A Serializer is used by subclassing it, and then declaring its
  # type, attributes, relations, and uniquely identifying field.
  #
  # The term 'fields' may refer to attributes of the model or the names of related
  # models, as in {http://jsonapi.org/format/#document-resource-object-fields
  # JSON:API resource object fields}
  #
  # @example
  #
  #  class ApplicationSerializer < AMS::Serializer; end
  #  class UserModelSerializer < ApplicationSerializer
  #    type :users
  #    id_field :id
  #    attribute :first_name, key: 'first-name'
  #    attribute :last_name, key: 'last-name'
  #    attribute :email
  #    relation :department, type: :departments, to: :one
  #    relation :roles, type: :roles, to: :many
  #  end
  #
  #  user = User.last
  #  ums = UserModelSerializer.new(user)
  #  ums.to_json
  class Serializer < BasicObject
    # delegate constant lookup to Object
    def self.const_missing(name)
      ::Object.const_get(name)
    end

    class << self
      attr_accessor :_attributes, :_relations, :_id_field, :_type

      # @api private
      # Macro to add an instance method to the receiver
      def add_instance_method(body, receiver = self)
        cl = caller_locations[0]
        silence_warnings { receiver.module_eval body, cl.absolute_path, cl.lineno }
      end

      # @api private
      # Macro to add a class method to the receiver
      def add_class_method(body, receiver)
        cl = caller_locations[0]
        silence_warnings { receiver.class_eval body, cl.absolute_path, cl.lineno }
      end

      # @api private
      # Silence warnings, primarily when redefining methods
      def silence_warnings
        original_verbose = $VERBOSE
        $VERBOSE = nil
        yield
      ensure
        $VERBOSE = original_verbose
      end

      # @!visibility private
      def _infer_type(base)
        Inflector.pluralize(
          Inflector.underscore(
            base.name.split("::")[-1].sub(/Serializer/, "")
          )
         )
      end

      def inherited(base)
        super
        base._attributes = _attributes.dup
        base._relations = _relations.dup
        base._type = _infer_type(base)

        add_class_method "def class; #{base}; end", base
        add_instance_method "def id; object.id; end", base
      end

      # Configure resource type
      # Inferred from serializer name by default
      #
      # @example
      #   type :users
      def type(type)
        self._type = type
      end

      # Configures the field on the object which uniquely identifies it.
      # By default, id `object.id`
      #
      # @example
      #   id_field :user_id
      def id_field(id_field)
        self._id_field = id_field
        add_instance_method <<-METHOD
        def id
          object.#{id_field}
        end
        METHOD
      end

      # @example
      #   attribute :color, key: :hue
      #
      #   1. Generates the method
      #     def color
      #       object.color
      #     end
      #   2. Stores the attribute :color
      #     with options key: :hue
      def attribute(attribute_name, key: attribute_name)
        fail "ForbiddenKey" if attribute_name == :id
        _attributes[attribute_name] = { key: key }
        add_instance_method <<-METHOD
        def #{attribute_name}
          object.#{attribute_name}
        end
        METHOD
      end

      #   1. Generates the methods
      #   2. Stores the relationship :articles with the given options
      #
      # @example
      #   relation :articles, type: :articles, to: :many, key: :posts
      #   relation :articles, type: :articles, to: :many, key: :posts, ids: "object.article_ids"
      #   relation :article, type: :articles, to: :one, key: :post
      #   relation :article, type: :articles, to: :one, key: :post, id: "object.article_id"
      def relation(relation_name, type:, to:, key: relation_name, **options)
        _relations[relation_name] = { key: key, type: type, to: to }
        case to
        when :many then _relation_to_many(relation_name, type: type, key: key, **options)
        when :one then _relation_to_one(relation_name, type: type, key: key, **options)
        else
          fail ArgumentError, "UnknownRelationship to='#{to}'"
        end
      end

      # @example
      #   relation :articles, type: :articles, to: :many, key: :posts
      #
      #     def related_articles_ids
      #       object.aritcles.pluck(:id)
      #     end
      #
      #     def articles
      #       relationship_object(related_articles_ids, :articles)
      #     end
      #
      # @example
      #   relation :articles, type: :articles, to: :many, key: :posts, ids: "object.article_ids"
      #
      #     def related_articles_ids
      #       object.article_ids
      #     end
      #
      #     def articles
      #       relationship_object(related_articles_ids, :articles)
      #     end
      def _relation_to_many(relation_name, type:, key: relation_name, **options)
        ids_method = options.fetch(:ids) do
          "object.#{relation_name}.pluck(:id)"
        end
        add_instance_method <<-METHOD
          def related_#{relation_name}_ids
            #{ids_method}
          end

          def #{relation_name}
            relationship_object(related_#{relation_name}_ids, "#{type}")
          end
        METHOD
      end

      # @example
      #   relation :article, type: :articles, to: :one, key: :post
      #
      #     def related_article_id
      #       object.article.id
      #     end
      #
      #     def article
      #       relationship_object(related_article_id, :articles)
      #     end
      #
      # @example
      #   relation :article, type: :articles, to: :one, key: :post, id: "object.article_id"
      #
      #     def related_article_id
      #       object.article_id
      #     end
      #
      #     def article
      #       relationship_object(related_article_id, :articles)
      #     end
      def _relation_to_one(relation_name, type:, key: relation_name, **options)
        id_method = options.fetch(:id) do
          "object.#{relation_name}.id"
        end
        add_instance_method <<-METHOD
          def related_#{relation_name}_id
            #{id_method}
          end

          def #{relation_name}
            id = related_#{relation_name}_id
            relationship_object(id, "#{type}")
          end
        METHOD
      end
    end
    self._attributes = {}
    self._relations = {}

    attr_reader :object

    # @param object [Object] the model whose data is used in serialization
    def initialize(object)
      @object = object
    end

    # Builds a Hash representation of the object
    # using id, type, attributes, relationships
    def to_h
      {
        id: id,
        type: type
      }.merge({
        attributes: attributes,
        relationships: relations
      }.reject { |_, v| v.empty? })
    end
    alias as_json to_h

    # Builds a JSON representation from as_json
    def to_json
      dump(as_json)
    end

    # Builds a Hash of specified attributes
    #
    # 1. For each configured attribute
    # 2.  map its :key to the attribute
    #
    # @example
    #   For the configured attribute:
    #
    #     attribute :color, key: :hue
    #
    #   The attributes hash will include:
    #
    #     attributes[:hue] = send(:color)
    #
    # TODO: Support sparse fieldsets
    def attributes
      fields = {}
      _attributes.each do |attribute_name, config|
        fields[config[:key]] = send(attribute_name)
      end
      fields
    end

    # Builds a Hash of specified relations
    #
    # 1. For each configured relation
    # 2.  map its :key to the relationship
    #
    # @example
    #   For the configured relation:
    #
    #     relation :user, key: :author
    #
    #   The relationships hash will include:
    #
    #     relations[:author] = send(:user)
    #
    # TODO: Support sparse fieldsets
    def relations
      fields = {}
      _relations.each do |relation_name, config|
        fields[config[:key]] = send(relation_name)
      end
      fields
    end

    # The configured type
    def type
      self.class._type
    end

    # The configured attributes
    def _attributes
      self.class._attributes
    end

    # The configured relations
    def _relations
      self.class._relations
    end

    # Builds a relationship object
    #
    # @example
    #   relationship_object(1, :users)
    #   #=> { data: { id: 1, type: :users} }
    #
    #   relationship_object([1,2], :users)
    #   #=> { data: [ { id: 1, type: :users}, { id: 2, type: :users] } }
    def relationship_object(id_or_ids, type)
      data =
        if id_or_ids.respond_to?(:to_ary)
          id_or_ids.map { |id| relationship_data(id, type) }
        else
          relationship_data(id_or_ids, type)
        end
      { "data": data }
    end

    # resource linkage
    def relationship_data(id, type)
      { "id": id, "type": type }
    end

    # Dumps obj to JSON
    # @param obj [Hash,Array,String,nil,Number]
    # @return [String] JSON
    def dump(obj)
      JSON.dump(obj)
    end

    # @!visibility private
    def send(*args)
      __send__(*args)
    end

    private

      def method_missing(name, *args, &block)
        object.send(name, *args, &block)
      end
  end
end
