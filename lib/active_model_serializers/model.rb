# ActiveModelSerializers::Model is a convenient superclass for making your models
# from Plain-Old Ruby Objects (PORO). It also serves as a reference implementation
# that satisfies ActiveModel::Serializer::Lint::Tests.
module ActiveModelSerializers
  class Model
    include ActiveModel::Serializers::JSON
    include ActiveModel::Model

    # Easily declare instance attributes with setters and getters for each.
    #
    # All attributes to initialize an instance must have setters.
    # However, the hash turned by +attributes+ instance method will ALWAYS
    # be the value of the initial attributes, regardless of what accessors are defined.
    # The only way to change the change the attributes after initialization is
    # to mutate the +attributes+ directly.
    # Accessor methods do NOT mutate the attributes.  (This is a bug).
    #
    # @note For now, the Model only supports the notion of 'attributes'.
    #   In the tests, there is a special Model that also supports 'associations'. This is
    #   important so that we can add accessors for values that should not appear in the
    #   attributes hash when modeling associations. It is not yet clear if it
    #   makes sense for a PORO to have associations outside of the tests.
    #
    # @overload attributes(names)
    #   @param names [Array<String, Symbol>]
    #   @param name [String, Symbol]
    def self.attributes(*names)
      # Silence redefinition of methods warnings
      ActiveModelSerializers.silence_warnings do
        attr_accessor(*names)
      end
    end

    # Support for validation and other ActiveModel::Errors
    # @return [ActiveModel::Errors]
    attr_reader :errors

    # (see #updated_at)
    attr_writer :updated_at

    # The only way to change the attributes of an instance is to directly mutate the attributes.
    # @example
    #
    #   model.attributes[:foo] = :bar
    # @return [Hash]
    attr_reader :attributes

    # @param attributes [Hash]
    def initialize(attributes = {})
      attributes ||= {} # protect against nil
      @attributes = attributes.symbolize_keys.with_indifferent_access
      @errors = ActiveModel::Errors.new(self)
      super
    end

    # Defaults to the downcased model name.
    # This probably isn't a good default, since it's not a unique instance identifier,
    # but that's what is currently implemented \_('-')_/.
    #
    # @note Though +id+ is defined, it will only show up
    #   in +attributes+ when it is passed in to the initializer or added to +attributes+,
    #   such as <tt>attributes[:id] = 5</tt>.
    # @return [String, Numeric, Symbol]
    def id
      attributes.fetch(:id) do
        defined?(@id) ? @id : self.class.model_name.name && self.class.model_name.name.downcase
      end
    end

    # When not set, defaults to the time the file was modified.
    #
    # @note Though +updated_at+ and +updated_at=+ are defined, it will only show up
    #   in +attributes+ when it is passed in to the initializer or added to +attributes+,
    #   such as <tt>attributes[:updated_at] = Time.current</tt>.
    # @return [String, Numeric, Time]
    def updated_at
      attributes.fetch(:updated_at) do
        defined?(@updated_at) ? @updated_at : File.mtime(__FILE__)
      end
    end

    # To customize model behavior, this method must be redefined. However,
    # there are other ways of setting the +cache_key+ a serializer uses.
    # @return [String]
    def cache_key
      ActiveSupport::Cache.expand_cache_key([
        self.class.model_name.name.downcase,
        "#{id}-#{updated_at.strftime('%Y%m%d%H%M%S%9N')}"
      ].compact)
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
  end
end
