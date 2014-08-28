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
end

Post = Class.new(Model)
Comment = Class.new(Model)

PostSerializer = Class.new(ActiveModel::Serializer) do
  attributes :title, :body, :id

  has_many :comments
end

CommentSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id, :body

  belongs_to :post
end
