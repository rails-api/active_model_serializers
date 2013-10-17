require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Schema.define do
  create_table :ar_posts, force: true do |t|
    t.string     :title
    t.text       :body
    t.belongs_to :ar_section, index: true
    t.timestamps
  end

  create_table :ar_comments, force: true do |t|
    t.text       :body
    t.belongs_to :ar_post, index: true
    t.timestamps
  end

  create_table :ar_tags, force: true do |t|
    t.string :name
  end

  create_table :ar_sections, force: true do |t|
    t.string :name
  end

  create_table :ar_posts_tags, force: true do |t|
    t.references :ar_post, :ar_tag, index: true
  end

  create_table :ar_comments_tags, force: true do |t|
    t.references :ar_comment, :ar_tag, index: true
  end
end

class ARPostsTag < ActiveRecord::Base
  belongs_to :ar_post, class_name: "ARPost"
  belongs_to :ar_tag, class_name: "ARTag"
end

class ARPost < ActiveRecord::Base
  has_many :ar_comments, class_name: 'ARComment'
  has_many :ar_post_tags, class_name: 'ARPostsTag'
  has_many :ar_tags, through: :ar_post_tags
  belongs_to :ar_section, class_name: 'ARSection'
end

class ARCommentsTag < ActiveRecord::Base
  belongs_to :ar_comment, class_name: 'ARCommentsTag'
  belongs_to :ar_tag, class_name: "ARTag"
end

class ARComment < ActiveRecord::Base
  belongs_to :ar_post, class_name: 'ARPost'
  has_many :ar_comment_tags, class_name: 'ARCommentsTag'
  has_many :ar_tags, through: :ar_comment_tags
end

class ARTag < ActiveRecord::Base
end

class ARSection < ActiveRecord::Base
end

class ARPostSerializer < ActiveModel::Serializer
  attributes :title, :body

  has_many :ar_comments, :ar_tags
  has_one  :ar_section
end

class ARCommentSerializer < ActiveModel::Serializer
  attributes :body

  has_many :ar_tags
end

class ARTagSerializer < ActiveModel::Serializer
  attributes :name
end

class ARSectionSerializer < ActiveModel::Serializer
  attributes :name
end

ARPost.create(title: 'New post',
              body:  'A body!!!',
              ar_section: ARSection.create(name: 'ruby')).tap do |post|

  short_tag = ARTag.create(name: 'short')
  whiny_tag = ARTag.create(name: 'whiny')
  happy_tag = ARTag.create(name: 'happy')

  post.ar_tags.concat short_tag, whiny_tag, happy_tag

  post.ar_comments.create(body: 'what a dumb post').tap do |comment|
    comment.ar_tags.concat short_tag, whiny_tag
  end

  post.ar_comments.create(body: 'i liked it').tap do |comment|
    comment.ar_tags.concat short_tag, happy_tag
  end

  post.save
end
