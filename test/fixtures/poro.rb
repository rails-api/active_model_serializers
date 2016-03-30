class Model
  def initialize(hash = {})
    @attributes = hash
  end

  def read_attribute_for_serialization(name)
    if name == :id || name == 'id'
      object_id
    elsif respond_to?(name)
      send name
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

class SpecialPost < Post
  def special_comment
    @speical_comment ||= Comment.new(content: 'special')
  end
end

class Type < Model
end

class SelfReferencingUser < Model
  def type
    @type ||= Type.new(name: 'N1')
  end
  def parent
    @parent ||= SelfReferencingUserParent.new(name: 'N1')
  end
end

class SelfReferencingUserParent < Model
  def type
    @type ||= Type.new(name: 'N2')
  end
  def parent
  end
end

class Comment < Model
end

class WebLog < Model
end

class Interview < Model
  def attachment
    @attachment ||= Image.new(url: 'U1')
  end
end

class Mail < Model
  def attachments
    @attachments ||= [Image.new(url: 'U1'),
                      Video.new(html: 'H1')]
  end
end

class Image < Model
end

class Video < Model
end

###
## Serializers
###
class UserSerializer < ActiveModel::Serializer
  attributes :name, :email

  has_one :profile
end

class TypeSerializer < ActiveModel::Serializer
  attributes :name
end

class SelfReferencingUserParentSerializer < ActiveModel::Serializer
  attributes :name
  has_one :type, serializer: TypeSerializer, embed: :ids, include: true
end

class SelfReferencingUserSerializer < ActiveModel::Serializer
  attributes :name

  has_one :type, serializer: TypeSerializer, embed: :ids, include: true
  has_one :parent, serializer: SelfReferencingUserSerializer, embed: :ids, include: true
end

class UserInfoSerializer < ActiveModel::Serializer
  has_one :user, serializer: UserSerializer
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

  def title
    keyword = serialization_options[:highlight_keyword]
    title = object.read_attribute_for_serialization(:title)
    title = title.gsub(keyword,"'#{keyword}'") if keyword
    title
  end

  has_many :comments
end

class SpecialPostSerializer < ActiveModel::Serializer
  attributes :title, :body
  has_many :comments, root: :comments, embed_in_root: true, embed: :ids
  has_one :special_comment, root: :comments, embed_in_root: true, embed: :ids
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

class InterviewSerializer < ActiveModel::Serializer
  attributes :text

  has_one :attachment, polymorphic: true
end

class MailSerializer < ActiveModel::Serializer
  attributes :body

  has_many :attachments, polymorphic: true
end

class ImageSerializer < ActiveModel::Serializer
  attributes :url
end

class VideoSerializer < ActiveModel::Serializer
  attributes :html
end

class ShortProfileSerializer < ::ProfileSerializer; end

module TestNamespace
  class ProfileSerializer < ::ProfileSerializer; end
  class UserSerializer    < ::UserSerializer;    end
end

ActiveModel::Serializer.setup do |config|
  config.default_key_type = :name
end

class NameKeyUserSerializer < ActiveModel::Serializer
  attributes :name, :email

  has_one :profile
end

class NameKeyPostSerializer < ActiveModel::Serializer
  attributes :title, :body

  has_many :comments
end

ActiveModel::Serializer.setup do |config|
  config.default_key_type = nil
end


