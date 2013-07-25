require 'test_helper'
require 'active_model/serializer'


module ActiveModel
  class Serializer
    class MetaTest < ActiveModel::TestCase
      def setup
        @model = ::Model.new({ :attr1 => 'value1', :attr2 => 'value2', :attr3 => 'value3' })
      end

      def test_meta
        model_serializer = ModelSerializer.new(@model, root: 'model', meta: { 'total' => 10 })

        assert_equal({
          'model' => {
            'attr1' => 'value1',
            'attr2' => 'value2'
          },
          'meta' => {
            'total' => 10
          }
        }, model_serializer.as_json)
      end

      def test_meta_using_meta_key
        model_serializer = ModelSerializer.new(@model, root: 'model', meta_key: :my_meta, my_meta: { 'total' => 10 })

        assert_equal({
          'model' => {
            'attr1' => 'value1',
            'attr2' => 'value2'
          },
          'my_meta' => {
            'total' => 10
          }
        }, model_serializer.as_json)
      end
    end
  end
end
