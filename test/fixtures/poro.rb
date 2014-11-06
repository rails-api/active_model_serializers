class Model
  def initialize(hash={})
    @attributes = hash
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

  def method_missing(meth, *args)
    if meth.to_s =~ /^(.*)=$/
      @attributes[$1.to_sym] = args[0]
    elsif @attributes.key?(meth)
      @attributes[meth]
    else
      super
    end
  end
end

class Profile < Model
end

class ProfileSerializer < ActiveModel::Serializer
  attributes :name, :description

  urls :posts, :comments
end

class ProfilePreviewSerializer < ActiveModel::Serializer
  attributes :name

  urls :posts, :comments
end

Post = Class.new(Model)
Comment = Class.new(Model)
Author = Class.new(Model)
Bio = Class.new(Model)
Blog = Class.new(Model)
Role = Class.new(Model)

PostSerializer = Class.new(ActiveModel::Serializer) do
  attributes :title, :body, :id

  has_many :comments
  belongs_to :author
  url :comments
end

CommentSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id, :body

  belongs_to :post
  belongs_to :author
end

AuthorSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id, :name

  has_many :posts, embed: :ids
  has_many :roles, embed: :ids
  belongs_to :bio
end

RoleSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id, :name

  belongs_to :author
end

BioSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id, :content

  belongs_to :author
end

BlogSerializer = Class.new(ActiveModel::Serializer) do
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
