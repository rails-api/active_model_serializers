require_relative './benchmarking_support'
require_relative './app'

time = 10
disable_gc = true
ActiveModelSerializers.config.key_transform = :unaltered

###########################################
# Setup active record models
##########################################
require 'active_record'
require 'sqlite3'
# ActiveRecord::Base.logger = Logger.new(STDERR)

# Change the following to reflect your database settings
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database:     ':memory:'
)

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

puts ActiveModelSerializers::SerializableResource.new(author, adapter: :attributes, include: 'profile,posts').serializable_hash

Benchmark.ams('AR: attributes', time: time, disable_gc: disable_gc) do
  ActiveModelSerializers::SerializableResource.new(author, adapter: :attributes, include: 'profile,posts').serializable_hash
end

Benchmark.ams('AR: json', time: time, disable_gc: disable_gc) do
  ActiveModelSerializers::SerializableResource.new(author, adapter: :json, include: 'profile,posts').serializable_hash
end

Benchmark.ams('AR: JSON API', time: time, disable_gc: disable_gc) do
  ActiveModelSerializers::SerializableResource.new(author, adapter: :json_api, include: 'profile,posts').serializable_hash
end
