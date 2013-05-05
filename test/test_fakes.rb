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
    self.comments_disabled = false
    self.author = nil
  end

  attr_accessor :comments, :comments_disabled, :author
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

class UserAttributesWithKeySerializer < ActiveModel::Serializer
  attributes :first_name => :f_name, :last_name => :l_name

  def serializable_hash
    attributes.merge(:ok => true).merge(options[:scope])
  end
end

class UserAttributesWithSomeKeySerializer < ActiveModel::Serializer
  attributes :first_name, :last_name => :l_name

  def serializable_hash
    attributes.merge(:ok => true).merge(options[:scope])
  end
end

class UserAttributesWithUnsymbolizableKeySerializer < ActiveModel::Serializer
  attributes :first_name, :last_name => :"last-name"

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
    hash = hash.merge(:super_user => true) if object.super_user?
    hash
  end
end

class CommentSerializer
  def initialize(comment, options={})
    @object = comment
  end

  attr_reader :object

  def serializable_hash
    { :title => @object.read_attribute_for_serialization(:title) }
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

class PostWithConditionalCommentsSerializer < ActiveModel::Serializer
  root :post
  attributes :title, :body
  has_many :comments, :serializer => CommentSerializer

  def include_associations!
    include! :comments unless object.comments_disabled
  end
end

class PostWithMultipleConditionalsSerializer < ActiveModel::Serializer
  root :post
  attributes :title, :body, :author
  has_many :comments, :serializer => CommentSerializer

  def include_comments?
    !object.comments_disabled
  end

  def include_author?
    scope.super_user?
  end
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

class BlogWithRootSerializer < BlogSerializer
  root true
end

class CustomPostSerializer < ActiveModel::Serializer
  attributes :title
end

class CustomBlog < Blog
  attr_accessor :public_posts, :public_user
end

class CustomBlogSerializer < ActiveModel::Serializer
  has_many :public_posts, :key => :posts, :serializer => PostSerializer
  has_one :public_user, :key => :user, :serializer => UserSerializer
end

class SomeSerializer < ActiveModel::Serializer
  attributes :some
end

class SomeObject < Struct.new(:some)
end

# Set up some classes for polymorphic testing
class Attachment < Model
  def attachable
    @attributes[:attachable]
  end

  def readable
    @attributes[:readable]
  end

  def edible
    @attributes[:edible]
  end
end
