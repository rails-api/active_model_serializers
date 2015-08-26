class Model
  extend ActiveModel::Naming
  FILE_DIGEST = Digest::MD5.hexdigest(File.open(__FILE__).read)

  def self.model_name
    @_model_name ||= ActiveModel::Name.new(self)
  end

  def to_model
    self
  end

  def initialize(hash={})
    @attributes = hash
  end

  def cache_key
    "#{self.class.name.downcase}/#{self.id}-#{self.updated_at.strftime("%Y%m%d%H%M%S%9N")}"
  end

  def serializable_hash(options = nil)
    @attributes
  end

  def read_attribute_for_serialization(name)
    if name == :id || name == 'id'
      id
    else
      @attributes[name]
    end
  end

  def id
    @attributes[:id] || @attributes['id'] || object_id
  end

  def to_param
    id.to_s
  end

  ### Helper methods, not required to be serializable
  #
  # Convenience for adding @attributes readers and writers

  def method_missing(meth, *args)
    if meth.to_s =~ /^(.*)=$/
      @attributes[$1.to_sym] = args[0]
    elsif @attributes.key?(meth)
      @attributes[meth]
    else
      super
    end
  end

  def cache_key_with_digest
    "#{cache_key}/#{FILE_DIGEST}"
  end

  def updated_at
    @attributes[:updated_at] ||= DateTime.now.to_time
  end
end

class Profile < Model
end

class ProfileSerializer < ActiveModel::Serializer
  attributes :name, :description

  urls :posts, :comments

  def arguments_passed_in?
    options[:my_options] == :accessible
  end
end

class ProfilePreviewSerializer < ActiveModel::Serializer
  attributes :name

  urls :posts, :comments
end

Post     = Class.new(Model)
Like     = Class.new(Model)
Author   = Class.new(Model)
Bio      = Class.new(Model)
Blog     = Class.new(Model)
Role     = Class.new(Model)
User     = Class.new(Model)
Location = Class.new(Model)
Place    = Class.new(Model)
Tag      = Class.new(Model)
VirtualValue = Class.new(Model)
Comment  = Class.new(Model) do
  # Uses a custom non-time-based cache key
  def cache_key
    "#{self.class.name.downcase}/#{self.id}"
  end
end
Tag = Class.new(Model)

module Spam; end
Spam::UnrelatedLink = Class.new(Model)

PostSerializer = Class.new(ActiveModel::Serializer) do
  cache key:'post', expires_in: 0.1, skip_digest: true
  attributes :id, :title, :body

  has_many :comments
  belongs_to :blog
  belongs_to :author
  url :comments

  def blog
    Blog.new(id: 999, name: "Custom blog")
  end

  def custom_options
    options
  end
end

SpammyPostSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id
  has_many :related

  def self.root_name
    'posts'
  end
end

CommentSerializer = Class.new(ActiveModel::Serializer) do
  cache expires_in: 1.day, skip_digest: true
  attributes :id, :body

  belongs_to :post
  belongs_to :author

  def custom_options
    options
  end
end

AuthorSerializer = Class.new(ActiveModel::Serializer) do
  cache key:'writer', skip_digest: true
  attributes :id, :name

  has_many :posts, embed: :ids
  has_many :roles, embed: :ids
  has_one :bio
end

RoleSerializer = Class.new(ActiveModel::Serializer) do
  cache only: [:name], skip_digest: true
  attributes :id, :name, :description, :slug

  def slug
    "#{name}-#{id}"
  end

  belongs_to :author
end

LikeSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id, :time

  belongs_to :likeable
end

LocationSerializer = Class.new(ActiveModel::Serializer) do
  cache only: [:place], skip_digest: true
  attributes :id, :lat, :lng

  belongs_to :place

  def place
    'Nowhere'
  end
end

PlaceSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id, :name

  has_many :locations
end

BioSerializer = Class.new(ActiveModel::Serializer) do
  cache except: [:content], skip_digest: true
  attributes :id, :content, :rating

  belongs_to :author
end

BlogSerializer = Class.new(ActiveModel::Serializer) do
  cache key: 'blog'
  attributes :id, :name

  belongs_to :writer
  has_many :articles
end

PaginatedSerializer = Class.new(ActiveModel::Serializer::ArraySerializer) do
  def json_key
    'paginated'
  end
end

AlternateBlogSerializer = Class.new(ActiveModel::Serializer) do
  attribute :id
  attribute :name, key: :title
end

CustomBlogSerializer = Class.new(ActiveModel::Serializer) do
  attribute :id
  attribute :special_attribute

  has_many :articles
end

CommentPreviewSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id

  belongs_to :post
end

AuthorPreviewSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id

  has_many :posts
end

PostPreviewSerializer = Class.new(ActiveModel::Serializer) do
  def self.root_name
    'posts'
  end

  attributes :title, :body, :id

  has_many :comments, serializer: CommentPreviewSerializer
  belongs_to :author, serializer: AuthorPreviewSerializer
end

PostWithTagsSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id

  has_many :tags
end

PostWithCustomKeysSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id

  has_many :comments, key: :reviews
  belongs_to :author, key: :writer
  has_one :blog, key: :site
end

LinkTagSerializer = Class.new(ActiveModel::Serializer) do
  has_many :posts, links: true, data: false
end

VirtualValueSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id

  has_many :reviews, virtual_value: [{id: 1}, {id: 2}]
  has_one :maker, virtual_value: {id: 1}

  def reviews
  end

  def maker
  end
end

Spam::UnrelatedLinkSerializer = Class.new(ActiveModel::Serializer) do
  cache only: [:id]
  attributes :id
end

RaiseErrorSerializer = Class.new(ActiveModel::Serializer) do
  def json_key
    raise StandardError, 'Intentional error for rescue_from test'
  end
end
