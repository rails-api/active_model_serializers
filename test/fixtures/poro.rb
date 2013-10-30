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

class Profile < Model
end

class Post < Model
  def comments
    @comments ||= [Comment.new(content: 'C1'),
                   Comment.new(content: 'C2')]
  end
end

class Comment < Model
end

class Interview < Model
  def attachment
    @attachments ||= Image.new(url: 'U1')
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

class ProfileSerializer < ActiveModel::Serializer
  def description
    description = object.read_attribute_for_serialization(:description)
    scope ? "#{description} - #{scope}" : description
  end

  attributes :name, :description
end

class PostSerializer < ActiveModel::Serializer
  attributes :title, :body

  has_many :comments
end

class CommentSerializer < ActiveModel::Serializer
  attributes :content
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