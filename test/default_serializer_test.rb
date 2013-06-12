require "test_helper"
require "test_fakes"

class DefaultSerializerTest < ActiveModel::TestCase

  def test_object_with_no_options
    object = Model.new
    serializer = ActiveModel::DefaultSerializer.new(object)
    assert_equal object.as_json, serializer.serializable_hash
  end

  def test_object_with_options
    object = Model.new
    serializer = ActiveModel::DefaultSerializer.new(object, something: "hello")
    assert_equal({something: "hello"}, serializer.options)
    assert_equal object.as_json, serializer.serializable_hash
  end

  def test_array
    array = [ {name: "Fred"} ]
    serializer = ActiveModel::DefaultSerializer.new(array)
    assert_equal array.as_json, serializer.serializable_hash
  end

end
