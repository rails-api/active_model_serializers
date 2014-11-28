require 'active_model/serializable'

module ActiveModel
  # DefaultSerializer
  #
  # Provides a constant interface for all items
  class DefaultSerializer
    include ActiveModel::Serializable

    attr_reader :object

    def initialize(object, options={})
      @object = object
      @wrap_in_array = options[:_wrap_in_array]
      @polymorphic = options[:polymorphic]
    end

    def as_json(options={})
      instrument('!serialize') do
        return [] if @object.nil? && @wrap_in_array
        hash = @object.as_json

        hash = {:type => type_name(@object), type_name(@object) => hash} \
          if @polymorphic && !@object.nil?

        @wrap_in_array ? [hash] : hash
      end
    end
    alias serializable_hash as_json
    alias serializable_object as_json

    private
    def instrumentation_keys
      [:object, :wrap_in_array]
    end

    def type_name(elem)
      elem.class.to_s.demodulize.underscore.to_sym
    end
  end
end
