require "test_helper"

class SerializerTest < ActiveModel::TestCase
  class Model
    def initialize(hash={})
      @attributes = hash
    end

    def read_attribute_for_serialization(name)
      @attributes[name]
    end

    def as_json(*)
      { :model => "Model" }
    end
  end

  class User
    include ActiveModel::SerializerSupport

    attr_accessor :superuser

    def initialize(hash={})
      @attributes = hash.merge(:first_name => "Jose", :last_name => "Valim", :password => "oh noes yugive my password")
    end

    def read_attribute_for_serialization(name)
      @attributes[name]
    end

    def super_user?
      @superuser
    end
  end

  class Post < Model
    def initialize(attributes)
      super(attributes)
      self.comments ||= []
    end

    attr_accessor :comments
    def active_model_serializer; PostSerializer; end
  end

  class Comment < Model
    def active_model_serializer; CommentSerializer; end
  end

  class UserSerializer < ActiveModel::Serializer
    attributes :first_name, :last_name

    def serializable_hash
      attributes.merge(:ok => true).merge(scope)
    end
  end

  class DefaultUserSerializer < ActiveModel::Serializer
    attributes :first_name, :last_name
  end

  class MyUserSerializer < ActiveModel::Serializer
    attributes :first_name, :last_name

    def serializable_hash
      hash = attributes
      hash = hash.merge(:super_user => true) if my_user.super_user?
      hash
    end
  end

  class CommentSerializer
    def initialize(comment, scope)
      @comment, @scope = comment, scope
    end

    def serializable_hash
      { :title => @comment.read_attribute_for_serialization(:title) }
    end

    def as_json(*)
      { :comment => serializable_hash }
    end
  end

  class PostSerializer < ActiveModel::Serializer
    attributes :title, :body
    has_many :comments, :serializer => CommentSerializer
  end

  def test_attributes
    user = User.new
    user_serializer = DefaultUserSerializer.new(user, {})

    hash = user_serializer.as_json

    assert_equal({
      :default_user => { :first_name => "Jose", :last_name => "Valim" }
    }, hash)
  end

  def test_attributes_method
    user = User.new
    user_serializer = UserSerializer.new(user, {})

    hash = user_serializer.as_json

    assert_equal({
      :user => { :first_name => "Jose", :last_name => "Valim", :ok => true }
    }, hash)
  end

  def test_serializer_receives_scope
    user = User.new
    user_serializer = UserSerializer.new(user, {:scope => true})

    hash = user_serializer.as_json

    assert_equal({
      :user => {
        :first_name => "Jose",
        :last_name => "Valim",
        :ok => true,
        :scope => true
      }
    }, hash)
  end

  def test_pretty_accessors
    user = User.new
    user.superuser = true
    user_serializer = MyUserSerializer.new(user, nil)

    hash = user_serializer.as_json

    assert_equal({
      :my_user => {
        :first_name => "Jose", :last_name => "Valim", :super_user => true
      }
    }, hash)
  end

  def test_has_many
    user = User.new

    post = Post.new(:title => "New Post", :body => "Body of new post", :email => "tenderlove@tenderlove.com")
    comments = [Comment.new(:title => "Comment1"), Comment.new(:title => "Comment2")]
    post.comments = comments

    post_serializer = PostSerializer.new(post, user)

    assert_equal({
      :post => {
        :title => "New Post",
        :body => "Body of new post",
        :comments => [
          { :title => "Comment1" },
          { :title => "Comment2" }
        ]
      }
    }, post_serializer.as_json)
  end

  class Blog < Model
    attr_accessor :author
  end

  class AuthorSerializer < ActiveModel::Serializer
    attributes :first_name, :last_name
  end

  class BlogSerializer < ActiveModel::Serializer
    has_one :author, :serializer => AuthorSerializer
  end

  def test_has_one
    user = User.new
    blog = Blog.new
    blog.author = user

    json = BlogSerializer.new(blog, user).as_json
    assert_equal({
      :blog => {
        :author => {
          :first_name => "Jose",
          :last_name => "Valim"
        }
      }
    }, json)
  end

  def test_implicit_serializer
    author_serializer = Class.new(ActiveModel::Serializer) do
      attributes :first_name
    end

    blog_serializer = Class.new(ActiveModel::Serializer) do
      const_set(:AuthorSerializer, author_serializer)
      has_one :author
    end

    user = User.new
    blog = Blog.new
    blog.author = user

    json = blog_serializer.new(blog, user).as_json
    assert_equal({
      :author => {
        :first_name => "Jose"
      }
    }, json)
  end

  def test_implicit_serializer_for_has_many
    blog_with_posts = Class.new(Blog) do
      attr_accessor :posts
    end

    blog_serializer = Class.new(ActiveModel::Serializer) do
      const_set(:PostSerializer, PostSerializer)
      has_many :posts
    end

    user = User.new
    blog = blog_with_posts.new
    blog.posts = [Post.new(:title => 'test')]

    json = blog_serializer.new(blog, user).as_json
    assert_equal({
     :posts => [{
       :title => "test", 
       :body => nil, 
       :comments => []
     }]
    }, json)
  end

  def test_overridden_associations
    author_serializer = Class.new(ActiveModel::Serializer) do
      attributes :first_name
    end

    blog_serializer = Class.new(ActiveModel::Serializer) do
      const_set(:PersonSerializer, author_serializer)

      def person
        object.author
      end

      has_one :person
    end

    user = User.new
    blog = Blog.new
    blog.author = user

    json = blog_serializer.new(blog, user).as_json
    assert_equal({
      :person => {
        :first_name => "Jose"
      }
    }, json)
  end

  def post_serializer(type)
    Class.new(ActiveModel::Serializer) do
      attributes :title, :body
      has_many :comments, :serializer => CommentSerializer

      if type != :super
        define_method :serializable_hash do
          post_hash = attributes
          post_hash.merge!(send(type))
          post_hash
        end
      end
    end
  end

  def test_associations
    post = Post.new(:title => "New Post", :body => "Body of new post", :email => "tenderlove@tenderlove.com")
    comments = [Comment.new(:title => "Comment1"), Comment.new(:title => "Comment2")]
    post.comments = comments

    serializer = post_serializer(:associations).new(post, nil)

    assert_equal({
      :title => "New Post",
      :body => "Body of new post",
      :comments => [
        { :title => "Comment1" },
        { :title => "Comment2" }
      ]
    }, serializer.as_json)
  end

  def test_association_ids
    serializer = post_serializer(:association_ids)

    serializer.class_eval do
      def as_json(*)
        { :post => serializable_hash }.merge(associations)
      end
    end

    post = Post.new(:title => "New Post", :body => "Body of new post", :email => "tenderlove@tenderlove.com")
    comments = [Comment.new(:title => "Comment1", :id => 1), Comment.new(:title => "Comment2", :id => 2)]
    post.comments = comments

    serializer = serializer.new(post, nil)

    assert_equal({
      :post => {
        :title => "New Post",
        :body => "Body of new post",
        :comments => [1, 2]
      },
      :comments => [
        { :title => "Comment1" },
        { :title => "Comment2" }
      ]
    }, serializer.as_json)
  end

  def test_associations_with_nil_association
    user = User.new
    blog = Blog.new

    json = BlogSerializer.new(blog, user).as_json
    assert_equal({
      :blog => { :author => nil }
    }, json)

    serializer = Class.new(BlogSerializer) do
      root :blog

      def serializable_hash
        attributes.merge(association_ids)
      end
    end

    json = serializer.new(blog, user).as_json
    assert_equal({ :blog =>  { :author => nil } }, json)
  end

  def test_custom_root
    user = User.new
    blog = Blog.new

    serializer = Class.new(BlogSerializer) do
      root :my_blog
    end

    assert_equal({ :my_blog => { :author => nil } }, serializer.new(blog, user).as_json)
  end

  def test_false_root
    user = User.new
    blog = Blog.new

    serializer = Class.new(BlogSerializer) do
      root false
    end

    assert_equal({ :author => nil }, serializer.new(blog, user).as_json)

    # test inherited false root
    serializer = Class.new(serializer)
    assert_equal({ :author => nil }, serializer.new(blog, user).as_json)
  end

  def test_embed_ids
    serializer = post_serializer(:super)

    serializer.class_eval do
      root :post
      embed :ids
    end

    post = Post.new(:title => "New Post", :body => "Body of new post", :email => "tenderlove@tenderlove.com")
    comments = [Comment.new(:title => "Comment1", :id => 1), Comment.new(:title => "Comment2", :id => 2)]
    post.comments = comments

    serializer = serializer.new(post, nil)

    assert_equal({
      :post => {
        :title => "New Post",
        :body => "Body of new post",
        :comments => [1, 2]
      }
    }, serializer.as_json)
  end

  def test_embed_ids_include_true
    serializer = post_serializer(:super)

    serializer.class_eval do
      root :post
      embed :ids, :include => true
    end

    post = Post.new(:title => "New Post", :body => "Body of new post", :email => "tenderlove@tenderlove.com")
    comments = [Comment.new(:title => "Comment1", :id => 1), Comment.new(:title => "Comment2", :id => 2)]
    post.comments = comments

    serializer = serializer.new(post, nil)

    assert_equal({
      :post => {
        :title => "New Post",
        :body => "Body of new post",
        :comments => [1, 2]
      },
      :comments => [
        { :title => "Comment1" },
        { :title => "Comment2" }
      ]
    }, serializer.as_json)
  end

  def test_embed_objects
    serializer = post_serializer(:super)

    serializer.class_eval do
      root :post
      embed :objects
    end

    post = Post.new(:title => "New Post", :body => "Body of new post", :email => "tenderlove@tenderlove.com")
    comments = [Comment.new(:title => "Comment1", :id => 1), Comment.new(:title => "Comment2", :id => 2)]
    post.comments = comments

    serializer = serializer.new(post, nil)

    assert_equal({
      :post => {
        :title => "New Post",
        :body => "Body of new post",
        :comments => [
          { :title => "Comment1" },
          { :title => "Comment2" }
        ]
      }
    }, serializer.as_json)
  end

  def test_array_serializer
    model    = Model.new
    user     = User.new
    comments = Comment.new(:title => "Comment1", :id => 1)

    array = [model, user, comments]
    serializer = array.active_model_serializer.new(array, {:scope => true})
    assert_equal([
      { :model => "Model" },
      { :user => { :last_name=>"Valim", :ok=>true, :first_name=>"Jose", :scope => true } },
      { :comment => { :title => "Comment1" } }
    ], serializer.as_json)
  end

  class CustomBlog < Blog
    attr_accessor :public_posts, :public_user
  end

  class CustomBlogSerializer < ActiveModel::Serializer
    has_many :public_posts, :key => :posts, :serializer => PostSerializer
    has_one :public_user, :key => :user, :serializer => UserSerializer
  end

  def test_associations_with_as
    posts = [
      Post.new(:title => 'First Post', :body => 'text'), 
      Post.new(:title => 'Second Post', :body => 'text')
    ]
    user = User.new

    custom_blog = CustomBlog.new
    custom_blog.public_posts = posts
    custom_blog.public_user = user

    serializer = CustomBlogSerializer.new(custom_blog, :scope => true)

    assert_equal({
      :custom_blog => {
        :posts => [
          {:title => 'First Post', :body => 'text', :comments => []},
          {:title => 'Second Post', :body => 'text', :comments => []}
        ],
        :user => {
          :first_name => "Jose", 
          :last_name => "Valim", :ok => true, 
          :scope => true
        }
      }
    }, serializer.as_json)
  end

  def test_implicity_detection_for_association_serializers 
    implicit_serializer = Class.new(ActiveModel::Serializer) do
      root :custom_blog
      const_set(:UserSerializer, UserSerializer)
      const_set(:PostSerializer, PostSerializer)

      has_many :public_posts, :key => :posts
      has_one :public_user, :key => :user
    end

    posts = [
      Post.new(:title => 'First Post', :body => 'text', :comments => []), 
      Post.new(:title => 'Second Post', :body => 'text', :comments => [])
    ]
    user = User.new

    custom_blog = CustomBlog.new
    custom_blog.public_posts = posts
    custom_blog.public_user = user

    serializer = implicit_serializer.new(custom_blog, :scope => true)

    assert_equal({
      :custom_blog => {
        :posts => [
          {:title => 'First Post', :body => 'text', :comments => []},
          {:title => 'Second Post', :body => 'text', :comments => []}
        ],
        :user => {
          :first_name => "Jose", 
          :last_name => "Valim", :ok => true, 
          :scope => true
        }
      }
    }, serializer.as_json)
  end

  def test_attribute_key
    serializer_class = Class.new(ActiveModel::Serializer) do
      root :user

      attribute :first_name, :key => :firstName
      attribute :last_name, :key => :lastName
      attribute :password
    end

    serializer = serializer_class.new(User.new, nil)

    assert_equal({
      :user => {
        :firstName => "Jose",
        :lastName => "Valim",
        :password => "oh noes yugive my password"
      }
    }, serializer.as_json)
  end

  def setup_model
    Class.new do
      class << self
        def columns_hash
          { :name => { :type => :string }, :age => { :type => :integer } }
        end

        def reflect_on_association(name)
          case name
          when :posts
            Struct.new(:macro, :name).new(:has_many, :posts)
          when :parent
            Struct.new(:macro, :name).new(:belongs_to, :parent)
          end
        end
      end
    end
  end

  def test_schema
    model = setup_model

    serializer = Class.new(ActiveModel::Serializer) do
      class << self; self; end.class_eval do
        define_method(:model_class) do model end
      end

      attributes :name, :age
      has_many :posts, :serializer => Class.new
      has_one :parent, :serializer => Class.new
    end

    assert_equal serializer.schema, {
      :attributes => { :name => :string, :age => :integer },
      :associations => {
        :posts => { :has_many => :posts },
        :parent => { :belongs_to => :parent }
      }
    }
  end

  def test_schema_with_as
    model = setup_model

    serializer = Class.new(ActiveModel::Serializer) do
      class << self; self; end.class_eval do
        define_method(:model_class) do model end
      end

      attributes :name, :age
      has_many :posts, :key => :my_posts, :serializer => Class.new
      has_one :parent, :key => :my_parent, :serializer => Class.new
    end

    assert_equal serializer.schema, {
      :attributes => { :name => :string, :age => :integer },
      :associations => {
        :my_posts => { :has_many => :posts },
        :my_parent => { :belongs_to => :parent }
      }
    }
  end

  def test_embed_id_for_has_one
    author_serializer = Class.new(ActiveModel::Serializer)

    serializer_class = Class.new(ActiveModel::Serializer) do
      embed :ids
      root :post

      attributes :title, :body
      has_one :author, :serializer => author_serializer
    end

    post_class = Class.new(Model) do
      attr_accessor :author
    end

    author_class = Class.new(Model)

    post = post_class.new(:title => "New Post", :body => "It's a new post!")
    author = author_class.new(:id => 5)
    post.author = author

    hash = serializer_class.new(post, nil)

    assert_equal({
      :post => {
        :title => "New Post",
        :body => "It's a new post!",
        :author => 5
      }
    }, hash.as_json)
  end

  def test_embed_objects_for_has_one
    author_serializer = Class.new(ActiveModel::Serializer) do
      attributes :id, :name
    end

    serializer_class = Class.new(ActiveModel::Serializer) do
      root :post

      attributes :title, :body
      has_one :author, :serializer => author_serializer
    end

    post_class = Class.new(Model) do
      attr_accessor :author
    end

    author_class = Class.new(Model)

    post = post_class.new(:title => "New Post", :body => "It's a new post!")
    author = author_class.new(:id => 5, :name => "Tom Dale")
    post.author = author

    hash = serializer_class.new(post, nil)

    assert_equal({
      :post => {
        :title => "New Post",
        :body => "It's a new post!",
        :author => { :id => 5, :name => "Tom Dale" }
      }
    }, hash.as_json)
  end
end
