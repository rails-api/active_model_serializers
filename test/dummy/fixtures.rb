Rails.configuration.serializers = []
class AuthorSerializer < ActiveModel::Serializer
  attributes :id, :name

  has_many :posts, embed: :ids
  has_one :bio
end
Rails.configuration.serializers << AuthorSerializer

class BlogSerializer < ActiveModel::Serializer
  attributes :id, :name
end
Rails.configuration.serializers << BlogSerializer

class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body

  belongs_to :post
  belongs_to :author
end
Rails.configuration.serializers << CommentSerializer

class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body

  has_many :comments, serializer: CommentSerializer
  belongs_to :blog, serializer: BlogSerializer
  belongs_to :author, serializer: AuthorSerializer

  def blog
    Blog.new(id: 999, name: 'Custom blog')
  end
end
Rails.configuration.serializers << PostSerializer

class CachingAuthorSerializer < AuthorSerializer
  cache key: 'writer', only: [:name], skip_digest: true
end
Rails.configuration.serializers << CachingAuthorSerializer

class CachingCommentSerializer < CommentSerializer
  cache expires_in: 1.day, skip_digest: true
end
Rails.configuration.serializers << CachingCommentSerializer

class CachingPostSerializer < PostSerializer
  cache key: 'post', expires_in: 0.1, skip_digest: true
  belongs_to :blog, serializer: BlogSerializer
  belongs_to :author, serializer: CachingAuthorSerializer
  has_many :comments, serializer: CachingCommentSerializer
end
Rails.configuration.serializers << CachingPostSerializer

# ActiveModelSerializers::Model is a convenient
# serializable class to inherit from when making
# serializable non-activerecord objects.
class DummyModel
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON

  attr_reader :attributes

  def initialize(attributes = {})
    @attributes = attributes
    super
  end

  # Defaults to the downcased model name.
  def id
    attributes.fetch(:id) { self.class.name.downcase }
  end

  # Defaults to the downcased model name and updated_at
  def cache_key
    attributes.fetch(:cache_key) { "#{self.class.name.downcase}/#{id}-#{updated_at.strftime("%Y%m%d%H%M%S%9N")}" }
  end

  # Defaults to the time the serializer file was modified.
  def updated_at
    attributes.fetch(:updated_at) { File.mtime(__FILE__) }
  end

  def read_attribute_for_serialization(key)
    if key == :id || key == 'id'
      attributes.fetch(key) { id }
    else
      attributes[key]
    end
  end
end

class Comment < DummyModel
  attr_accessor :id, :body

  def cache_key
    "#{self.class.name.downcase}/#{id}"
  end
end

class Author < DummyModel
  attr_accessor :id, :name, :posts
end

class Post < DummyModel
  attr_accessor :id, :title, :body, :comments, :blog, :author

  def cache_key
    'benchmarking::post/1-20151215212620000000000'
  end
end

class Blog < DummyModel
  attr_accessor :id, :name
end
