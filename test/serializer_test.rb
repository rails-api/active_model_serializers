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
      self.author = nil
    end

    attr_accessor :comments, :author
    def active_model_serializer; PostSerializer; end
  end

  class Comment < Model
    def active_model_serializer; CommentSerializer; end
  end

  class UserSerializer < ActiveModel::Serializer
    attributes :first_name, :last_name

    def serializable_hash
      attributes.merge(:ok => true).merge(options[:scope])
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
    def initialize(comment, scope, options={})
      @comment, @scope = comment, scope
    end

    def serializable_hash
      { :title => @comment.read_attribute_for_serialization(:title) }
    end

    def as_json(options=nil)
      options ||= {}
      if options[:root] == false
        serializable_hash
      else
        { :comment => serializable_hash }
      end
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
    user_serializer = UserSerializer.new(user, :scope => {})

    hash = user_serializer.as_json

    assert_equal({
      :user => { :first_name => "Jose", :last_name => "Valim", :ok => true }
    }, hash)
  end

  def test_serializer_receives_scope
    user = User.new
    user_serializer = UserSerializer.new(user, :scope => {:scope => true})

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

  def test_serializer_receives_url_options
    user = User.new
    user_serializer = UserSerializer.new(user, :url_options => { :host => "test.local" })
    assert_equal({ :host => "test.local" }, user_serializer.url_options)
  end

  def test_pretty_accessors
    user = User.new
    user.superuser = true
    user_serializer = MyUserSerializer.new(user)

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

    post_serializer = PostSerializer.new(post, :scope => user)

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

    json = BlogSerializer.new(blog, :scope => user).as_json
    assert_equal({
      :blog => {
        :author => {
          :first_name => "Jose",
          :last_name => "Valim"
        }
      }
    }, json)
  end

  def test_overridden_associations
    author_serializer = Class.new(ActiveModel::Serializer) do
      attributes :first_name
    end

    blog_serializer = Class.new(ActiveModel::Serializer) do
      def person
        object.author
      end

      has_one :person, :serializer => author_serializer
    end

    user = User.new
    blog = Blog.new
    blog.author = user

    json = blog_serializer.new(blog, :scope => user).as_json
    assert_equal({
      :person => {
        :first_name => "Jose"
      }
    }, json)
  end

  def post_serializer
    Class.new(ActiveModel::Serializer) do
      attributes :title, :body
      has_many :comments, :serializer => CommentSerializer
      has_one :author, :serializer => DefaultUserSerializer
    end
  end

  def test_associations_with_nil_association
    user = User.new
    blog = Blog.new

    json = BlogSerializer.new(blog, :scope => user).as_json
    assert_equal({
      :blog => { :author => nil }
    }, json)

    serializer = Class.new(BlogSerializer) do
      root :blog
    end

    json = serializer.new(blog, :scope => user).as_json
    assert_equal({ :blog =>  { :author => nil } }, json)
  end

  def test_custom_root
    user = User.new
    blog = Blog.new

    serializer = Class.new(BlogSerializer) do
      root :my_blog
    end

    assert_equal({ :my_blog => { :author => nil } }, serializer.new(blog, :scope => user).as_json)
  end

  def test_false_root
    user = User.new
    blog = Blog.new

    serializer = Class.new(BlogSerializer) do
      root false
    end

    assert_equal({ :author => nil }, serializer.new(blog, :scope => user).as_json)

    # test inherited false root
    serializer = Class.new(serializer)
    assert_equal({ :author => nil }, serializer.new(blog, :scope => user).as_json)
  end

  def test_embed_ids
    serializer = post_serializer

    serializer.class_eval do
      root :post
      embed :ids
    end

    post = Post.new(:title => "New Post", :body => "Body of new post", :email => "tenderlove@tenderlove.com")
    comments = [Comment.new(:title => "Comment1", :id => 1), Comment.new(:title => "Comment2", :id => 2)]
    post.comments = comments

    serializer = serializer.new(post)

    assert_equal({
      :post => {
        :title => "New Post",
        :body => "Body of new post",
        :comments => [1, 2],
        :author => nil
      }
    }, serializer.as_json)
  end

  def test_embed_ids_include_true
    serializer_class = post_serializer

    serializer_class.class_eval do
      root :post
      embed :ids, :include => true
    end

    post = Post.new(:title => "New Post", :body => "Body of new post", :email => "tenderlove@tenderlove.com")
    comments = [Comment.new(:title => "Comment1", :id => 1), Comment.new(:title => "Comment2", :id => 2)]
    post.comments = comments

    serializer = serializer_class.new(post)

    assert_equal({
      :post => {
        :title => "New Post",
        :body => "Body of new post",
        :comments => [1, 2],
        :author => nil
      },
      :comments => [
        { :title => "Comment1" },
        { :title => "Comment2" }
      ],
      :authors => []
    }, serializer.as_json)

    post.author = User.new(:id => 1)

    serializer = serializer_class.new(post)

    assert_equal({
      :post => {
        :title => "New Post",
        :body => "Body of new post",
        :comments => [1, 2],
        :author => 1
      },
      :comments => [
        { :title => "Comment1" },
        { :title => "Comment2" }
      ],
      :authors => [{ :first_name => "Jose", :last_name => "Valim" }]
    }, serializer.as_json)
  end

  def test_embed_objects
    serializer = post_serializer

    serializer.class_eval do
      root :post
      embed :objects
    end

    post = Post.new(:title => "New Post", :body => "Body of new post", :email => "tenderlove@tenderlove.com")
    comments = [Comment.new(:title => "Comment1", :id => 1), Comment.new(:title => "Comment2", :id => 2)]
    post.comments = comments

    serializer = serializer.new(post)

    assert_equal({
      :post => {
        :title => "New Post",
        :body => "Body of new post",
        :author => nil,
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

  def test_array_serializer
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
    assert_equal({ :items => [ hash ]}, serializer.as_json)
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

    serializer = CustomBlogSerializer.new(custom_blog, :scope => { :scope => true })

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

    serializer = implicit_serializer.new(custom_blog, :scope => { :scope => true })

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

    serializer = serializer_class.new(User.new)

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
          { "name" => Struct.new(:type).new(:string), "age" => Struct.new(:type).new(:integer) }
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

    hash = serializer_class.new(post)

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

    hash = serializer_class.new(post)

    assert_equal({
      :post => {
        :title => "New Post",
        :body => "It's a new post!",
        :author => { :id => 5, :name => "Tom Dale" }
      }
    }, hash.as_json)
  end

  def test_root_provided_in_options
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

    assert_equal({
      :blog_post => {
        :title => "New Post",
        :body => "It's a new post!",
        :author => { :id => 5, :name => "Tom Dale" }
      }
    }, serializer_class.new(post, :root => :blog_post).as_json)

    assert_equal({
      :title => "New Post",
      :body => "It's a new post!",
      :author => { :id => 5, :name => "Tom Dale" }
    }, serializer_class.new(post, :root => false).as_json)

    assert_equal({
      :blog_post => {
        :title => "New Post",
        :body => "It's a new post!",
        :author => { :id => 5, :name => "Tom Dale" }
      }
    }, serializer_class.new(post).as_json(:root => :blog_post))

    assert_equal({
      :title => "New Post",
      :body => "It's a new post!",
      :author => { :id => 5, :name => "Tom Dale" }
    }, serializer_class.new(post).as_json(:root => false))
  end

  def test_serializer_has_access_to_root_object
    hash_object = nil

    author_serializer = Class.new(ActiveModel::Serializer) do
      attributes :id, :name

      define_method :serializable_hash do
        hash_object = @options[:hash]
        super()
      end
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

    expected = serializer_class.new(post).as_json
    assert_equal expected, hash_object
  end
  
  def test_embed_ids_include_true_with_root
    serializer_class = post_serializer

    serializer_class.class_eval do
      root :post
      embed :ids, :include => true
      has_many :comments, :key => :comment_ids, :root => :comments
      has_one :author, :serializer => DefaultUserSerializer, :key => :author_id, :root => :author
    end

    post = Post.new(:title => "New Post", :body => "Body of new post", :email => "tenderlove@tenderlove.com")
    comments = [Comment.new(:title => "Comment1", :id => 1), Comment.new(:title => "Comment2", :id => 2)]
    post.comments = comments

    serializer = serializer_class.new(post)

    assert_equal({
    :post => {
      :title => "New Post",
      :body => "Body of new post",
      :comment_ids => [1, 2],
      :author_id => nil
    },
    :comments => [
      { :title => "Comment1" },
      { :title => "Comment2" }
    ],
    :author => []
    }, serializer.as_json)

    post.author = User.new(:id => 1)

    serializer = serializer_class.new(post)

    assert_equal({
    :post => {
      :title => "New Post",
      :body => "Body of new post",
      :comment_ids => [1, 2],
      :author_id => 1
    },
    :comments => [
      { :title => "Comment1" },
      { :title => "Comment2" }
    ],
    :author => [{ :first_name => "Jose", :last_name => "Valim" }]
    }, serializer.as_json)
  end
  
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

  def test_can_customize_attributes
    serializer = Class.new(ActiveModel::Serializer) do
      attributes :title, :body

      def title
        object.title.upcase
      end
    end

    klass = Class.new do
      def read_attribute_for_serialization(name)
        { :title => "New post!", :body => "First post body" }[name]
      end

      def title
        read_attribute_for_serialization(:title)
      end

      def body
        read_attribute_for_serialization(:body)
      end
    end

    object = klass.new

    actual = serializer.new(object, :root => :post).as_json

    assert_equal({
      :post => {
        :title => "NEW POST!",
        :body => "First post body"
      }
    }, actual)
  end

  def test_can_customize_attributes_with_read_attributes
    serializer = Class.new(ActiveModel::Serializer) do
      attributes :title, :body

      def read_attribute_for_serialization(name)
        { :title => "New post!", :body => "First post body" }[name]
      end
    end

    actual = serializer.new(Object.new, :root => :post).as_json

    assert_equal({
      :post => {
        :title => "New post!",
        :body => "First post body"
      }
    }, actual)
  end

  def test_active_support_on_load_hooks_fired
    loaded = nil
    ActiveSupport.on_load(:active_model_serializers) do
      loaded = self
    end
    assert_equal ActiveModel::Serializer, loaded
  end
end
