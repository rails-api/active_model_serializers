require 'test_helper'

module ActiveModelSerializers
  class ModelMixinTest < ActiveSupport::TestCase
    def setup
      @klass = Class.new do
        #include ActiveModelSerializers::ModelMixin
        attr_accessor :key, :id
        def self.name
          'TestModel'
        end
      end
    end

    def test_poro_serialize
      serializer = Class.new(ActiveModel::Serializer) do
        attributes :key
      end
      model_instance = @klass.new
      model_instance.key = 'value'

      json = serializer.new(model_instance, {}).as_json
      assert_equal({ key: 'value' }, json)
    end
  end
end
