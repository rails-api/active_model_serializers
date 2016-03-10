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

if ENV['ENABLE_ACTIVE_RECORD'] == 'true'
  require 'active_record'

  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
  ActiveRecord::Schema.define do
    self.verbose = false

    create_table :blogs, force: true do |t|
      t.string :name
      t.timestamps null: false
    end
    create_table :authors, force: true do |t|
      t.string :name
      t.timestamps null: false
    end
    create_table :posts, force: true do |t|
      t.string :title
      t.text :body
      t.references :author
      t.references :blog
      t.timestamps null: false
    end
    create_table :comments, force: true do |t|
      t.text :body
      t.references :author
      t.references :post
      t.timestamps null: false
    end
  end

  class Comment < ActiveRecord::Base
    belongs_to :author
    belongs_to :post
  end

  class Author < ActiveRecord::Base
    has_many :posts
    has_many :comments
  end

  class Post < ActiveRecord::Base
    has_many :comments
    belongs_to :author
    belongs_to :blog
  end

  class Blog < ActiveRecord::Base
    has_many :posts
  end
else
  # ActiveModelSerializers::Model is a convenient
  # serializable class to inherit from when making
  # serializable non-activerecord objects.
  class BenchmarkModel
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
      attributes.fetch(:cache_key) { "#{self.class.name.downcase}/#{id}" }
    end

    # Defaults to the time the serializer file was modified.
    def updated_at
      @updated_at ||= attributes.fetch(:updated_at) { File.mtime(__FILE__) }
    end

    def read_attribute_for_serialization(key)
      if key == :id || key == 'id'
        attributes.fetch(key) { id }
      else
        attributes[key]
      end
    end
  end

  class Comment < BenchmarkModel
    attr_accessor :id, :body
  end

  class Author < BenchmarkModel
    attr_accessor :id, :name, :posts
  end

  class Post < BenchmarkModel
    attr_accessor :id, :title, :body, :comments, :blog, :author
  end

  class Blog < BenchmarkModel
    attr_accessor :id, :name
  end
end
