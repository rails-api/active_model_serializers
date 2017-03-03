###########################################
# Setup active record models
##########################################
require 'active_record'
require 'sqlite3'


# Change the following to reflect your database settings
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# Don't show migration output when constructing fake db
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :authors, force: true do |t|
    t.string :name
  end

  create_table :posts, force: true do |t|
    t.text :body
    t.string :title
    t.references :author
  end

  create_table :profiles, force: true do |t|
    t.text :project_url
    t.text :bio
    t.date :birthday
    t.references :author
  end
end

class Author < ActiveRecord::Base
  has_one :profile
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :author
end

class Profile < ActiveRecord::Base
  belongs_to :author
end

# Build out the data to serialize
author = Author.create(name: 'Preston Sego')
Profile.create(project_url: 'https://github.com/NullVoxPopuli', author: author)
50.times do
  Post.create(
    body: 'something about how password restrictions are evil, and less secure, and with the math to prove it.',
    title: 'Your bank is does not know how to do security',
    author: author
  )
end

ActiveModel::Serializer.root = false
ActiveModel::ArraySerializer.root = false

class FlatAuthorSerializer < ActiveModel::Serializer
  attributes :id, :name
end

class AuthorWithDefaultRelationshipsSerializer < ActiveModel::Serializer
  attributes :id, :name

  has_one :profile
  has_many :posts
end

# For debugging SQL output
#ActiveRecord::Base.logger = Logger.new(STDERR)
