require 'active_support/core_ext/hash/keys'

module ActiveModelSerializers
  module KeyTransform
    module_function

    # Transforms keys to UpperCamelCase or PascalCase.
    #
    # @example:
    #    "some_key" => "SomeKey",
    # @see {https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L66-L76 ActiveSupport::Inflector.camelize}
    def camel(hash)
      hash.deep_transform_keys! { |key| key.to_s.camelize.to_sym }
    end

    # Transforms keys to camelCase.
    #
    # @example:
    #    "some_key" => "someKey",
    # @see {https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L66-L76 ActiveSupport::Inflector.camelize}
    def camel_lower(hash)
      hash.deep_transform_keys! { |key| key.to_s.camelize(:lower).to_sym }
    end

    # Transforms keys to dashed-case.
    # This is the default case for the JsonApi adapter.
    #
    # @example:
    #    "some_key" => "some-key",
    # @see {https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L185-L187 ActiveSupport::Inflector.dasherize}
    def dashed(hash)
      hash.deep_transform_keys! { |key| key.to_s.dasherize.to_sym }
    end

    # Transforms keys to underscore.
    # This is the default case for deserialization in the JsonApi adapter.
    #
    # @example:
    #    "some-key" => "some_key",
    # @see {https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L89-L98 ActiveSupport::Inflector.underscore}
    def underscore(hash)
      hash.deep_transform_keys! { |key| key.to_s.underscore.to_sym }
    end

    # Returns the hash unaltered
    def unaltered(hash)
      hash
    end

    # Transforms string to selected case
    # Accepts string in any case: 'camel', 'undescore', 'dashed'.
    #
    # @example:
    #   transform('SomeClass', :underscore) => 'some_class'
    #   transform('some_class', :snake) => 'someClass'
    #   etc...
    def transform(string, type)
      string = string.underscore
      case type.to_sym
      when :dashed
        string.dasherize
      when :camel
        string.camelize
      when :snake
        string.camelize(:lower)
      else
        string
      end
    end
  end
end
