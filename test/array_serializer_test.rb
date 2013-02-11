require "test_helper"
require "test_fakes"

class ArraySerializerTest < ActiveModel::TestCase
  # serialize different typed objects
  def test_array_serializer
    model    = Model.new
    user     = User.new
    comments = Comment.new(:title => "Comment1", :id => 1)

    array = [model, user, comments]
    serializer = array.active_model_serializer.new(array, :scope => {:scope => true})
    assert_equal([
      { :model => "Model" },
      { :last_name => "Valim", :ok => true, :first_name => "Jose", :scope => true },
      { :title => "Comment1" }
    ], serializer.as_json)
  end

  def test_array_serializer_with_root
    comment1 = Comment.new(:title => "Comment1", :id => 1)
    comment2 = Comment.new(:title => "Comment2", :id => 2)

    array = [ comment1, comment2 ]

    serializer = array.active_model_serializer.new(array, :root => :comments)

    assert_equal({ :comments => [
      { :title => "Comment1" },
      { :title => "Comment2" }
    ]}, serializer.as_json)
  end

  def test_array_serializer_with_hash
    hash = {:value => "something"}
    array = [hash]
    serializer = array.active_model_serializer.new(array, :root => :items)
    assert_equal({ :items => [ hash.as_json ]}, serializer.as_json)
  end

  def test_array_serializer_with_specified_seriailizer
    post1 = Post.new(:title => "Post1", :author => "Author1", :id => 1)
    post2 = Post.new(:title => "Post2", :author => "Author2", :id => 2)

    array = [ post1, post2 ]

    serializer = array.active_model_serializer.new array, :each_serializer => CustomPostSerializer

    assert_equal([
      { :title => "Post1" },
      { :title => "Post2" }
    ], serializer.as_json)
  end
end
