require "test_helper"
require "test_fakes"

class SerializerTest < ActiveModel::TestCase

  # the point of this test is to illustrate that deeply nested serializers
  # still side-load at the root.
  def test_embed_with_include_inserts_at_root
    tag_serializer = Class.new(ActiveModel::Serializer) do
      attributes :id, :name
    end

    comment_serializer = Class.new(ActiveModel::Serializer) do
      embed :ids, :include => true
      attributes :id, :body
      has_many :tags, :serializer => tag_serializer
    end

    post_serializer = Class.new(ActiveModel::Serializer) do
      embed :ids, :include => true
      attributes :id, :title, :body
      has_many :comments, :serializer => comment_serializer
    end

    post_class = Class.new(Model) do
      attr_accessor :comments

      define_method :active_model_serializer do
        post_serializer
      end
    end

    comment_class = Class.new(Model) do
      attr_accessor :tags
    end

    tag_class = Class.new(Model)

    post = post_class.new(:title => "New Post", :body => "NEW POST", :id => 1)
    comment1 = comment_class.new(:body => "EWOT", :id => 1)
    comment2 = comment_class.new(:body => "YARLY", :id => 2)
    tag1 = tag_class.new(:name => "lolcat", :id => 1)
    tag2 = tag_class.new(:name => "nyancat", :id => 2)
    tag3 = tag_class.new(:name => "violetcat", :id => 3)

    post.comments = [comment1, comment2]
    comment1.tags = [tag1, tag3]
    comment2.tags = [tag1, tag2]

    actual = ActiveModel::ArraySerializer.new([post], :root => :posts).as_json
    assert_equal({
      :posts => [
        { :title => "New Post", :body => "NEW POST", :id => 1, :comments => [1,2] }
      ],

      :comments => [
        { :body => "EWOT", :id => 1, :tags => [1,3] },
        { :body => "YARLY", :id => 2, :tags => [1,2] }
      ],

      :tags => [
        { :name => "lolcat", :id => 1 },
        { :name => "violetcat", :id => 3 },
        { :name => "nyancat", :id => 2 }
      ]
    }, actual)
  end

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