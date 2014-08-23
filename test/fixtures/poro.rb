class Model
  def initialize(hash={})
    @attributes = hash
  end

  def read_attribute_for_serialization(name)
    if name == :id || name == 'id'
      object_id
    else
      @attributes[name]
    end
  end
end


###
## Models
###
class User < Model
  def profile
    @profile ||= Profile.new(name: 'N1', description: 'D1')
  end
end

class UserInfo < Model
  def user
    @user ||= User.new(name: 'N1', email: 'E1')
  end
end

class Profile < Model
end

class Category < Model
  def posts
    @posts ||= [Post.new(title: 'T1', body: 'B1'),
                Post.new(title: 'T2', body: 'B2')]
  end
end

class Post < Model
  def comments
    @comments ||= [Comment.new(content: 'C1'),
                   Comment.new(content: 'C2')]
  end
end

class Comment < Model
end

class WebLog < Model
end

###
## Serializers
###
class UserSerializer < ActiveModel::Serializer
  attributes :name, :email

  has_one :profile
end

class UserInfoSerializer < ActiveModel::Serializer
  has_one :user
end

class ProfileSerializer < ActiveModel::Serializer
  def description
    description = object.read_attribute_for_serialization(:description)
    scope ? "#{description} - #{scope}" : description
  end

  attributes :name, :description
end

class CategorySerializer < ActiveModel::Serializer
  attributes :name

  has_many :posts
end

class PostSerializer < ActiveModel::Serializer
  attributes :title, :body

  has_many :comments
end

class CommentSerializer < ActiveModel::Serializer
  attributes :content
end

class WebLogSerializer < ActiveModel::Serializer
  attributes :name, :display_name
end

class WebLogLowerCamelSerializer < WebLogSerializer
  format_keys :lower_camel
end
