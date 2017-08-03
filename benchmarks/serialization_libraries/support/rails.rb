require 'sqlite3'
db_file = File.join(File.dirname(__FILE__), 'bench.sqlite3')
db = SQLite3::Database.new(db_file)
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: db_file)

ActiveRecord::Schema.define(version: 20_170_620_020_730) do
  create_table 'comments', force: :cascade do |t|
    t.integer 'post_id'
    t.string 'author'
    t.string 'comment'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['post_id'], name: 'index_comments_on_post_id'
  end

  create_table 'posts', force: :cascade do |t|
    t.integer 'user_id'
    t.string 'title'
    t.string 'body'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['user_id'], name: 'index_posts_on_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'first_name'
    t.string 'last_name'
    t.datetime 'birthday'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Comment < ApplicationRecord
  belongs_to :post
end

class Post < ApplicationRecord
  has_many :comments
  belongs_to :user
end

class User < ApplicationRecord
  has_many :posts
end
