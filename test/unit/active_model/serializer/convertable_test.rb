require 'test_helper'
def MiniTest.filter_backtrace(bt)
  bt
end

module ActiveModel
  class Serializer
    class CamelCaseLowerTest < ActiveModel::TestCase
      def setup
        @camel_case = CamelCase.new({ key_one: 'Name 1', key_two: 'Name 2' })
        @camel_case_serializer = CamelCaseSerializer.new(@camel_case)
        @camel_case_serializer.class_eval do
          camelize_keys!
        end
      end

      def test_attributes_definition
        assert_equal([:key_one, :key_two],
                     @camel_case_serializer.class._attributes)
      end

      def test_convert_keys_using_serializable_hash
        assert_equal({
          'keyOne' => 'Name 1', 'keyTwo' => 'Name 2'
        }, @camel_case_serializer.serializable_hash)
      end

      def test_convert_keys_using_as_json
        assert_equal({
          'camelCase' => { 'keyOne' => 'Name 1', 'keyTwo' => 'Name 2' }
        }, @camel_case_serializer.as_json)
      end
    end

    class CamelCaseUpperTest < ActiveModel::TestCase
      def setup
        @camel_case = CamelCase.new({ key_one: 'Name 1', key_two: 'Name 2' })
        @camel_case_serializer = CamelCaseSerializer.new(@camel_case)
        @camel_case_serializer.class_eval do
          camelize_keys! :upper
        end
      end

      def test_attributes_definition
        assert_equal([:key_one, :key_two],
                     @camel_case_serializer.class._attributes)
      end

      def test_convert_keys_using_serializable_hash
        assert_equal({
          'KeyOne' => 'Name 1', 'KeyTwo' => 'Name 2'
        }, @camel_case_serializer.serializable_hash)
      end

      def test_convert_keys_using_as_json
        assert_equal({
          'CamelCase' => { 'KeyOne' => 'Name 1', 'KeyTwo' => 'Name 2' }
        }, @camel_case_serializer.as_json)
      end
    end
  end
end
