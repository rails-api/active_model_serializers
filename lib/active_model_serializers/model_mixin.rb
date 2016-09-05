# ActiveModelSerializers::Model is a convenient
# serializable class to inherit from when making
# serializable non-activerecord objects.
module ActiveModelSerializers
  module ModelMixin
    def self.included(klass)
      klass.class_eval do
        include ActiveModel::Model
        include ActiveModel::Serializers::JSON

        def read_attribute_for_serialization(key)
          if key == :id || key == 'id'
            send(key)
          else
            if is_a?(ActiveModelSerializers::Model)
              # Support legacy behavior
              attributes[key] || (send(key) if respond_to?(key))
            else
              send(key) if respond_to?(key)
            end
          end
        end
      end
    end

    #def id
      #self.class.name.downcase
    #end

    #def cache_key
    #end

    #def errors
      #@errors ||= ActiveModel::Errors.new(self)
    #end

    #def updated_at
    #end

    # This is just to make lint pass
    # We shouldnt have this...
    #def attributes
      #{}
    #end

    # The following methods are needed to be minimally implemented for ActiveModel::Errors
    # :nocov:
    #def self.human_attribute_name(attr, _options = {})
      #attr
    #end

    #def self.lookup_ancestors
      #[self]
    #end
    # :nocov:
  end
end
