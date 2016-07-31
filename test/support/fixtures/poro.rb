verbose = $VERBOSE
$VERBOSE = nil
class Model < ActiveModelSerializers::Model
  FILE_DIGEST = Digest::MD5.hexdigest(File.open(__FILE__).read)

  ### Helper methods, not required to be serializable

  # Convenience when not adding @attributes readers and writers
  def method_missing(meth, *args)
    if meth.to_s =~ /^(.*)=$/
      attributes[Regexp.last_match(1).to_sym] = args[0]
    elsif attributes.key?(meth)
      attributes[meth]
    else
      super
    end
  end

  # required for ActiveModel::AttributeAssignment#_assign_attribute
  # in Rails 5
  def respond_to_missing?(method_name, _include_private = false)
    attributes.key?(method_name.to_s.tr('=', '').to_sym) || super
  end
end

# see
# https://github.com/rails/rails/blob/4-2-stable/activemodel/lib/active_model/errors.rb
# The below allows you to do:
#
#   model = ModelWithErrors.new
#   model.validate!            # => ["cannot be nil"]
#   model.errors.full_messages # => ["name cannot be nil"]
class ModelWithErrors < ::ActiveModelSerializers::Model
  attr_accessor :name
end

class Profile < Model
end

class ProfileSerializer < ActiveModel::Serializer
  attributes :name, :description

  # TODO: is this used anywhere?
  def arguments_passed_in?
    instance_options[:my_options] == :accessible
  end
end

class ProfilePreviewSerializer < ActiveModel::Serializer
  attributes :name
end

class Post < Model; end
class Like < Model; end
class Author < Model; end
class Bio < Model; end
class Blog < Model; end
class Role < Model; end
class User < Model; end
class Location < Model; end
class Place < Model; end
class Tag < Model; end
class VirtualValue < Model; end
class Comment < Model
  # Uses a custom non-time-based cache key
  def cache_key
    "#{self.class.name.downcase}/#{id}"
  end
end

class Employee < ActiveRecord::Base
  has_many :pictures, as: :imageable
  has_many :object_tags, as: :taggable
end

class ObjectTag < ActiveRecord::Base
  belongs_to :poly_tag
  belongs_to :taggable, polymorphic: true
end

class Picture < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true
  has_many :object_tags, as: :taggable
end

class PolyTag < ActiveRecord::Base
  has_many :object_tags
end

module Spam
  class UnrelatedLink < Model; end
end

class PostSerializer < ActiveModel::Serializer
  cache key: 'post', expires_in: 0.1, skip_digest: true
  attributes :id, :title, :body

  has_many :comments
  belongs_to :blog
  belongs_to :author

  def blog
    Blog.new(id: 999, name: 'Custom blog')
  end

  # TODO: is this used anywhere?
  def custom_options
    instance_options
  end
end

class SpammyPostSerializer < ActiveModel::Serializer
  attributes :id
  has_many :related
end

class CommentSerializer < ActiveModel::Serializer
  cache expires_in: 1.day, skip_digest: true
  attributes :id, :body

  belongs_to :post
  belongs_to :author

  def custom_options
    instance_options
  end
end

class AuthorSerializer < ActiveModel::Serializer
  cache key: 'writer', skip_digest: true
  attribute :id
  attribute :name

  has_many :posts
  has_many :roles
  has_one :bio
end

class RoleSerializer < ActiveModel::Serializer
  cache only: [:name, :slug], skip_digest: true
  attributes :id, :name, :description
  attribute :friendly_id, key: :slug

  def friendly_id
    "#{object.name}-#{object.id}"
  end

  belongs_to :author
end

class LikeSerializer < ActiveModel::Serializer
  attributes :id, :time

  belongs_to :likeable
end

class LocationSerializer < ActiveModel::Serializer
  cache only: [:address], skip_digest: true
  attributes :id, :lat, :lng

  belongs_to :place, key: :address

  def place
    'Nowhere'
  end
end

class PlaceSerializer < ActiveModel::Serializer
  attributes :id, :name

  has_many :locations
end

class BioSerializer < ActiveModel::Serializer
  cache except: [:content], skip_digest: true
  attributes :id, :content, :rating

  belongs_to :author
end

class BlogSerializer < ActiveModel::Serializer
  cache key: 'blog'
  attributes :id, :name

  belongs_to :writer
  has_many :articles
end

class PaginatedSerializer < ActiveModel::Serializer::CollectionSerializer
  def json_key
    'paginated'
  end
end

class AlternateBlogSerializer < ActiveModel::Serializer
  attribute :id
  attribute :name, key: :title
end

class CustomBlogSerializer < ActiveModel::Serializer
  attribute :id
  attribute :special_attribute

  has_many :articles
end

class CommentPreviewSerializer < ActiveModel::Serializer
  attributes :id

  belongs_to :post
end

class AuthorPreviewSerializer < ActiveModel::Serializer
  attributes :id

  has_many :posts
end

class PostPreviewSerializer < ActiveModel::Serializer
  attributes :title, :body, :id

  has_many :comments, serializer: CommentPreviewSerializer
  belongs_to :author, serializer: AuthorPreviewSerializer
end

class PostWithTagsSerializer < ActiveModel::Serializer
  attributes :id

  has_many :tags
end

class PostWithCustomKeysSerializer < ActiveModel::Serializer
  attributes :id

  has_many :comments, key: :reviews
  belongs_to :author, key: :writer
  has_one :blog, key: :site
end

class VirtualValueSerializer < ActiveModel::Serializer
  attributes :id

  has_many :reviews, virtual_value: [{ type: 'reviews', id: '1' },
                                     { type: 'reviews', id: '2' }]
  has_one :maker, virtual_value: { type: 'makers', id: '1' }

  def reviews
  end

  def maker
  end
end

class PolymorphicHasManySerializer < ActiveModel::Serializer
  attributes :id, :name
end

class PolymorphicBelongsToSerializer < ActiveModel::Serializer
  attributes :id, :title

  has_one :imageable, serializer: PolymorphicHasManySerializer, polymorphic: true
end

class PolymorphicSimpleSerializer < ActiveModel::Serializer
  attributes :id
end

class PolymorphicObjectTagSerializer < ActiveModel::Serializer
  attributes :id

  has_many :taggable, serializer: PolymorphicSimpleSerializer, polymorphic: true
end

class PolymorphicTagSerializer < ActiveModel::Serializer
  attributes :id, :phrase

  has_many :object_tags, serializer: PolymorphicObjectTagSerializer
end

module Spam
  class UnrelatedLinkSerializer < ActiveModel::Serializer
    cache only: [:id]
    attributes :id
  end
end
$VERBOSE = verbose
