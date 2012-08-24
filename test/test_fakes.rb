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
  def initialize(comment, options={})
    @comment = comment
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

class CustomPostSerializer < ActiveModel::Serializer
  attributes :title
end
