require 'active_model/default_serializer'
require 'active_model/serializable'
require 'active_model/serializer'

module ActiveModel
  class ArraySerializer
    include Serializable

    class << self
      def configuration
        @configuration ||=
          if self == ArraySerializer
            Serializer::Configuration.global
          else
            superclass.configuration.build
          end
      end
    end

    extend Forwardable

    def_delegators :configuration, :scope, :root, :meta_key, :meta, :each_serializer, :resource_name

    attr_accessor :object, :configuration

    def initialize(object, options = {})
      @object        = object
      @configuration = self.class.configuration.build options
    end

    def json_key
      if root.nil?
        resource_name
      else
        root
      end
    end

    def serializer_for(item)
      serializer_class = each_serializer || Serializer.serializer_for(item) || DefaultSerializer
      serializer_class.new(item, scope: scope)
    end

    def serializable_object
      object.map do |item|
        serializer_for(item).serializable_object
      end
    end
    alias_method :serializable_array, :serializable_object

    def embedded_in_root_associations
      object.each_with_object({}) do |item, hash|
        serializer_for(item).embedded_in_root_associations.each_pair do |type, objects|
          next if !objects || objects.flatten.empty?

          if hash.has_key?(type)
            hash[type].concat(objects).uniq!
          else
            hash[type] = objects
          end
        end
      end
    end
  end
end
