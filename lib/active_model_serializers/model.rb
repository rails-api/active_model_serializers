# ActiveModelSerializers::Model is a convenient superclass when making serializable non-activerecord objects.
# It also serves as documentation of an implementation that satisfies ActiveModel::Serializer::Lint::Tests.
module ActiveModelSerializers
  class Model
    include ActiveModel::Serializers::JSON
    include ActiveModel::Model

    # @method :attributes
    #   - unset attributes will appear in nil values in the attributes hash
    #   - instance attributes can ONLY be changed by accessor methods.
    #   - the return value of the attributes method is now frozen. since it is always derived, trying to mutate it is strongly discouraged :)
    #
    # @method :attributes_are_always_the_initialization_data
    #
    # When true, the deprecate attribute behavior is mixed in.
    # Defaults to +true+, in order to avoid breaking changes with older versions of this class which lacked defined attributes.
    #
    # However, new apps probably want to change the default to false, and old apps want to create a special new model subclass where it is false for use in new models.
    #
    # Specifically, the deprecated behavior this re-adds is:
    #   - the attributes hash returned by `#attributes` will always be the value of the attributes passed in at initialization,
    #     regardless of what attr_* methods were defined.
    #   - unset attributes, rather than being nil, will not be included in the attributes hash, even when an `attr_accessor` exists.
    #   - the only way to change the change the attributes after initialization is to mutate the `attributes` directly.  Accessor methods
    #     will NOT mutate the attributes.  (This is the bug that led to the change).
    #
    # For now, the Model only supports the notion of 'attributes'. In the tests, we do support 'associations' on the PORO,
    # in order to adds accessors for values that should not appear in the attributes hash, as we model associations.
    # However, it is not yet clear if it makes sense for a PORO to have associations outside of the tests.
    class_attribute :attributes_are_always_the_initialization_data, instance_writer: false, instance_reader: false
    self.attributes_are_always_the_initialization_data = true

    def self.inherited(subclass)
      if subclass.attributes_are_always_the_initialization_data
        unless subclass.included_modules.include?(AttributesAreAlwaysTheInitializationData)
          subclass.prepend(AttributesAreAlwaysTheInitializationData)
        end
      end
      super
    end

    # @method :attribute_names
    # Is only available as a class-method since the ActiveModel::Serialization mixin in Rails
    # uses an +attribute_names+ local variable, which may conflict if we were to add instance methods here.
    class_attribute :attribute_names, instance_writer: false, instance_reader: false
    # Initialize +attribute_names+ for all subclasses.  The array is usually
    # mutated in the +attributes+ method, but can be set directly, as well.
    self.attribute_names = []

    def self.attributes(*names)
      self.attribute_names |= names.map(&:to_sym)
      # Silence redefinition of methods warnings, since it is expected.
      ActiveModelSerializers.silence_warnings do
        attr_accessor(*names)
      end
    end

    # NOTE that +updated_at+ isn't included in +attribute_names+,
    # which means it won't show up in +attributes+ unless a subclass has
    # either <tt>attributes :updated_at</tt> which will redefine the methods
    # or <tt>attribute_names << :updated_at</tt>.
    attr_writer :updated_at

    # NOTE that +id+ will always be in +attributes+.
    attributes :id

    # Support for validation and other ActiveModel::Errors
    attr_reader :errors

    def initialize(attributes = {})
      @errors = ActiveModel::Errors.new(self)
      super
    end

    # The the fields in +attribute_names+ determines the returned hash.
    # +attributes+ are returned frozen to prevent any expectations that mutation affects
    # the actual values in the model.
    def attributes
      self.class.attribute_names.each_with_object({}) do |attribute_name, result|
        result[attribute_name] = public_send(attribute_name).freeze
      end.with_indifferent_access.freeze
    end

    # To customize model behavior, this method must be redefined. However,
    # there are other ways of setting the +cache_key+ a serializer uses.
    def cache_key
      ActiveSupport::Cache.expand_cache_key([
        self.class.model_name.name.downcase,
        "#{id}-#{updated_at.strftime('%Y%m%d%H%M%S%9N')}"
      ].compact)
    end

    # When not set, defaults to the time the file was modified.
    # See NOTE by attr_writer :updated_at
    def updated_at
      defined?(@updated_at) ? @updated_at : File.mtime(__FILE__)
    end

    # The following methods are needed to be minimally implemented for ActiveModel::Errors
    # :nocov:
    def self.human_attribute_name(attr, _options = {})
      attr
    end

    def self.lookup_ancestors
      [self]
    end
    # :nocov:

    module AttributesAreAlwaysTheInitializationData
      def initialize(attributes = {})
        @initialized_attributes = attributes && attributes.symbolize_keys
        super
      end

      # Defaults to the downcased model name.
      # This probably isn't a good default, since it's not a unique instance identifier,
      # but that was the old behavior ¯\_(ツ)_/¯
      def id
        @initialized_attributes.fetch(:id) { self.class.model_name.name && self.class.model_name.name.downcase }
      end

      # The only way to change the attributes of an instance is to directly mutate the attributes.
      #
      #   model.attributes[:foo] = :bar
      def attributes
        @initialized_attributes
      end
    end
  end
end
