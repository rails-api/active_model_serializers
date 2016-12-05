# ActiveModelSerializers::Model is a convenient
# serializable class to inherit from when making
# serializable non-activerecord objects.
module ActiveModelSerializers
  class Model
    include ActiveModel::Serializers::JSON
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
    extend ActiveModel::Translation

    class_attribute :attribute_names
    self.attribute_names = []

    def self.attributes(*names)
      attr_accessor(*names)
      self.attribute_names = attribute_names | names.map(&:to_sym)
    end

    attributes :id
    attr_writer :updated_at

    # Defaults to the downcased model name.
    def id
      @id ||= self.class.name.downcase
    end

    # Defaults to the downcased model name and updated_at
    def cache_key
      "#{self.class.name.downcase}/#{id}-#{updated_at.strftime('%Y%m%d%H%M%S%9N')}"
    end

    # Defaults to the time the serializer file was modified.
    def updated_at
      defined?(@updated_at) ? @updated_at : File.mtime(__FILE__)
    end

    attr_reader :errors

    def initialize(attributes = {})
      assign_attributes(attributes) if attributes
      @errors = ActiveModel::Errors.new(self)
      super()
    end

    def attributes
      attribute_names.each_with_object({}) do |attribute_name, result|
        result[attribute_name] = public_send(attribute_name)
      end.with_indifferent_access
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

    def assign_attributes(new_attributes)
      unless new_attributes.respond_to?(:stringify_keys)
        fail ArgumentError, 'When assigning attributes, you must pass a hash as an argument.'
      end
      return if new_attributes.blank?

      attributes = new_attributes.stringify_keys
      _assign_attributes(attributes)
    end

    private

    def _assign_attributes(attributes)
      attributes.each do |k, v|
        _assign_attribute(k, v)
      end
    end

    def _assign_attribute(k, v)
      fail UnknownAttributeError.new(self, k) unless respond_to?("#{k}=")
      public_send("#{k}=", v)
    end

    def persisted?
      false
    end

    # Raised when unknown attributes are supplied via mass assignment.
    class UnknownAttributeError < NoMethodError
      attr_reader :record, :attribute

      def initialize(record, attribute)
        @record = record
        @attribute = attribute
        super("unknown attribute '#{attribute}' for #{@record.class}.")
      end
    end
  end
end
