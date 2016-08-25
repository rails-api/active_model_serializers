require 'active_support/core_ext/hash/keys'

module ActiveModelSerializers
  module KeyTransform
    module_function

    # Transforms values to UpperCamelCase or PascalCase.
    #
    # @example:
    #    "some_key" => "SomeKey",
    # @see {https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L66-L76 ActiveSupport::Inflector.camelize}
    def camel(value)
      case value
      when Array then value.map { |item| camel(item) }
      when Hash then value.deep_transform_keys! { |key| camel(key) }
      when Symbol then camel(value.to_s).to_sym
      when String then value.underscore.camelize
      else value
      end
    end

    # Transforms values to camelCase.
    #
    # @example:
    #    "some_key" => "someKey",
    # @see {https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L66-L76 ActiveSupport::Inflector.camelize}
    def camel_lower(value)
      case value
      when Array then value.map { |item| camel_lower(item) }
      when Hash then value.deep_transform_keys! { |key| camel_lower(key) }
      when Symbol then camel_lower(value.to_s).to_sym
      when String then value.underscore.camelize(:lower)
      else value
      end
    end

    # Transforms values to dashed-case.
    # This is the default case for the JsonApi adapter.
    #
    # @example:
    #    "some_key" => "some-key",
    # @see {https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L185-L187 ActiveSupport::Inflector.dasherize}
    def dash(value)
      case value
      when Array then value.map { |item| dash(item) }
      when Hash then value.deep_transform_keys! { |key| dash(key) }
      when Symbol then dash(value.to_s).to_sym
      when String then value.underscore.dasherize
      else value
      end
    end

    # Transforms values to underscore_case.
    # This is the default case for deserialization in the JsonApi adapter.
    #
    # @example:
    #    "some-key" => "some_key",
    # @see {https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L89-L98 ActiveSupport::Inflector.underscore}
    def underscore(value)
      case value
      when Array then value.map { |item| underscore(item) }
      when Hash then value.deep_transform_keys! { |key| underscore(key) }
      when Symbol then underscore(value.to_s).to_sym
      when String then value.underscore
      else value
      end
    end

    # Returns the value unaltered
    def unaltered(value)
      value
    end
  end
end
