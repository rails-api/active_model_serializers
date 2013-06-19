require "test_helper"
require "test_fakes"

class ArraySerializerTest < ActiveModel::TestCase
  # serialize different typed objects
  def test_array_serializer
    model    = Model.new
    user     = User.new
    comments = Comment.new(title: "Comment1", id: 1)

    array = [model, user, comments]
    serializer = array.active_model_serializer.new(array, scope: { scope: true })
    assert_equal([
      { model: "Model" },
      { last_name: "Valim", ok: true, first_name: "Jose", scope: true },
      { title: "Comment1" }
    ], serializer.as_json)
  end

  def test_array_serializer_with_root
    comment1 = Comment.new(title: "Comment1", id: 1)
    comment2 = Comment.new(title: "Comment2", id: 2)

    array = [ comment1, comment2 ]

    serializer = array.active_model_serializer.new(array, root: :comments)

    assert_equal({ comments: [
      { title: "Comment1" },
      { title: "Comment2" }
    ]}, serializer.as_json)
  end

  def test_active_model_with_root
    comment1 = ModelWithActiveModelSerializer.new(title: "Comment1")
    comment2 = ModelWithActiveModelSerializer.new(title: "Comment2")

    array = [ comment1, comment2 ]

    serializer = array.active_model_serializer.new(array, root: :comments)

    assert_equal({ comments: [
      { title: "Comment1" },
      { title: "Comment2" }
    ]}, serializer.as_json)
  end

  def test_array_serializer_with_hash
    hash = { value: "something" }
    array = [hash]
    serializer = array.active_model_serializer.new(array, root: :items)
    assert_equal({ items: [hash.as_json] }, serializer.as_json)
  end

  def test_array_serializer_with_specified_serializer
    post1 = Post.new(title: "Post1", author: "Author1", id: 1)
    post2 = Post.new(title: "Post2", author: "Author2", id: 2)

    array = [ post1, post2 ]

    serializer = array.active_model_serializer.new array, each_serializer: CustomPostSerializer

    assert_equal([
      { title: "Post1" },
      { title: "Post2" }
    ], serializer.as_json)
  end

  def test_array_serializer_using_default_serializer
    hash = { "value" => "something" }
    class << hash
      def active_model_serializer
        nil
      end
    end

    array = [hash]

    serializer = array.active_model_serializer.new array

    assert_equal([
      { "value" => "something" }
    ], serializer.as_json)
  end

  def test_active_support_on_load_hooks_fired
    loaded = nil
    ActiveSupport.on_load(:active_model_array_serializers) do
      loaded = self
    end
    assert_equal ActiveModel::ArraySerializer, loaded
  end

  def test_serializer_receives_url_options
    array = []
    options = {url_options: { host: "test.local" }}
    serializer = array.active_model_serializer.new(array, options)

    assert_equal({ host: "test.local" }, serializer.url_options)
  end

  def test_serializer_returns_empty_hash_without_url_options
    array = []
    serializer = array.active_model_serializer.new array

    assert_equal({}, serializer.url_options)
  end
end
