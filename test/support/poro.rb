module ActiveModelSerializersWithoutLegacyModelSupport
  module_function

  def poro_without_legacy_model_support(superklass = ActiveModelSerializers::Model, &block)
    original_attributes_are_always_the_initialization_data = superklass.attributes_are_always_the_initialization_data
    superklass.attributes_are_always_the_initialization_data = false
    Class.new(superklass) do
      class_exec(&block) if block
    end
  ensure
    superklass.attributes_are_always_the_initialization_data = original_attributes_are_always_the_initialization_data
  end
end
Minitest::Test.include ActiveModelSerializersWithoutLegacyModelSupport
Minitest::Test.extend ActiveModelSerializersWithoutLegacyModelSupport
