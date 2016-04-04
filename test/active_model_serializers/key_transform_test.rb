require 'test_helper'

class ActiveModelSerializers::KeyTransformTest < ActiveSupport::TestCase
  def test_camel
    obj = Object.new
    scenarios = [
      {
        value: { :"some-key" => 'value' },
        expected: { :SomeKey => 'value' }
      },
      {
        value: { :someKey => 'value' },
        expected: { :SomeKey => 'value' }
      },
      {
        value: { :some_key => 'value' },
        expected: { :SomeKey => 'value' }
      },
      {
        value: { 'some-key' => 'value' },
        expected: { 'SomeKey' => 'value' }
      },
      {
        value: { 'someKey' => 'value' },
        expected: { 'SomeKey' => 'value' }
      },
      {
        value: { 'some_key' => 'value' },
        expected: { 'SomeKey' => 'value' }
      },
      {
        value: :"some-value",
        expected: :SomeValue
      },
      {
        value: :some_value,
        expected: :SomeValue
      },
      {
        value: :someValue,
        expected: :SomeValue
      },
      {
        value: 'some-value',
        expected: 'SomeValue'
      },
      {
        value: 'someValue',
        expected: 'SomeValue'
      },
      {
        value: 'some_value',
        expected: 'SomeValue'
      },
      {
        value: obj,
        expected: obj
      },
      {
        value: nil,
        expected: nil
      }
    ]
    scenarios.each do |s|
      result = ActiveModelSerializers::KeyTransform.camel(s[:value])
      assert_equal s[:expected], result
    end
  end

  def test_camel_lower
    obj = Object.new
    scenarios = [
      {
        value: { :"some-key" => 'value' },
        expected: { :someKey => 'value' }
      },
      {
        value: { :SomeKey => 'value' },
        expected: { :someKey => 'value' }
      },
      {
        value: { :some_key => 'value' },
        expected: { :someKey => 'value' }
      },
      {
        value: { 'some-key' => 'value' },
        expected: { 'someKey' => 'value' }
      },
      {
        value: { 'SomeKey' => 'value' },
        expected: { 'someKey' => 'value' }
      },
      {
        value: { 'some_key' => 'value' },
        expected: { 'someKey' => 'value' }
      },
      {
        value: :"some-value",
        expected: :someValue
      },
      {
        value: :SomeValue,
        expected: :someValue
      },
      {
        value: :some_value,
        expected: :someValue
      },
      {
        value: 'some-value',
        expected: 'someValue'
      },
      {
        value: 'SomeValue',
        expected: 'someValue'
      },
      {
        value: 'some_value',
        expected: 'someValue'
      },
      {
        value: obj,
        expected: obj
      },
      {
        value: nil,
        expected: nil
      }
    ]
    scenarios.each do |s|
      result = ActiveModelSerializers::KeyTransform.camel_lower(s[:value])
      assert_equal s[:expected], result
    end
  end

  def test_dash
    obj = Object.new
    scenarios = [
      {
        value: { :some_key => 'value' },
        expected: { :"some-key" => 'value' }
      },
      {
        value: { 'some_key' => 'value' },
        expected: { 'some-key' => 'value' }
      },
      {
        value: { :SomeKey => 'value' },
        expected: { :"some-key" => 'value' }
      },
      {
        value: { 'SomeKey' => 'value' },
        expected: { 'some-key' => 'value' }
      },
      {
        value: { :someKey => 'value' },
        expected: { :"some-key" => 'value' }
      },
      {
        value: { 'someKey' => 'value' },
        expected: { 'some-key' => 'value' }
      },
      {
        value: :some_value,
        expected: :"some-value"
      },
      {
        value: :SomeValue,
        expected: :"some-value"
      },
      {
        value: 'SomeValue',
        expected: 'some-value'
      },
      {
        value: :someValue,
        expected: :"some-value"
      },
      {
        value: 'someValue',
        expected: 'some-value'
      },
      {
        value: obj,
        expected: obj
      },
      {
        value: nil,
        expected: nil
      }
    ]
    scenarios.each do |s|
      result = ActiveModelSerializers::KeyTransform.dash(s[:value])
      assert_equal s[:expected], result
    end
  end

  def test_underscore
    obj = Object.new
    scenarios = [
      {
        value: { :"some-key" => 'value' },
        expected: { :some_key => 'value' }
      },
      {
        value: { 'some-key' => 'value' },
        expected: { 'some_key' => 'value' }
      },
      {
        value: { :SomeKey => 'value' },
        expected: { :some_key => 'value' }
      },
      {
        value: { 'SomeKey' => 'value' },
        expected: { 'some_key' => 'value' }
      },
      {
        value: { :someKey => 'value' },
        expected: { :some_key => 'value' }
      },
      {
        value: { 'someKey' => 'value' },
        expected: { 'some_key' => 'value' }
      },
      {
        value: :"some-value",
        expected: :some_value
      },
      {
        value: :SomeValue,
        expected: :some_value
      },
      {
        value: :someValue,
        expected: :some_value
      },
      {
        value: 'some-value',
        expected: 'some_value'
      },
      {
        value: 'SomeValue',
        expected: 'some_value'
      },
      {
        value: 'someValue',
        expected: 'some_value'
      },
      {
        value: obj,
        expected: obj
      },
      {
        value: nil,
        expected: nil
      }
    ]
    scenarios.each do |s|
      result = ActiveModelSerializers::KeyTransform.underscore(s[:value])
      assert_equal s[:expected], result
    end
  end
end
