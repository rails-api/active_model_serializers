# ActiveModelSerializers::Model is a convenient
# serializable class to inherit from when making
# serializable non-activerecord objects.
module ActiveModelSerializers
  class Model
    include ActiveModel::Serializers::JSON
    include ActiveModel::Model

    class_attribute :attribute_names
    # Initialize +attribute_names+ for all subclasses.  The array is usually
    # mutated in the +attributes+ method, but can be set directly, as well.
    self.attribute_names = []

    def self.attributes(*names)
      self.attribute_names |= names.map(&:to_sym)
      # Silence redefinition of methods warnings
      ActiveModelSerializers.silence_warnings do
        attr_accessor(*names)
      end
    end

    attr_reader :errors
    # NOTE that +updated_at+ isn't included in +attribute_names+,
    # which means it won't show up in +attributes+ unless a subclass has
    # either <tt>attributes :updated_at</tt> which will redefine the methods
    # or <tt>attribute_names << :updated_at</tt>.
    attr_writer :updated_at
    # NOTE that +id+ will always be in +attributes+.
    attributes :id

    def initialize(attributes = {})
      @errors = ActiveModel::Errors.new(self)
      super
    end

    # The the fields in +attribute_names+ determines the returned hash.
    # +attributes+ are returned frozen to prevent any expectations that mutation affects
    # the actual values in the model.
    def attributes
      attribute_names.each_with_object({}) do |attribute_name, result|
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

    # When no set, defaults to the time the file was modified.
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
  end
end
