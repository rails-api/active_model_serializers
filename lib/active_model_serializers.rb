require 'jsonapi/serializable'

require 'active_model_serializers/version'
require 'active_model_serializers/formatters/attributes'
require 'active_model_serializers/formatters/json'
require 'active_model_serializers/serializer'

module ActiveModelSerializers
  ADAPTERS = [:json, :attributes, :jsonapi]

  module_function

  def adapter=(name)
    symbol_name = name.to_sym
    raise 'adapter not allowed' unless ADAPTERS.include?(symbol_name)

    @adapter = symbol_name
  end

  def adapter
    @adapter
  end
end
