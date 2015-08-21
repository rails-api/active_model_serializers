require 'test_helper'
require 'active_record'

module ActiveModel
  class Serializer
    class DeserializeTest < Minitest::Test
      def setup
        super
        ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
        ActiveRecord::Schema.define do
          create_table :posts, force: true do |t|
            t.string :title
            t.text :body
            t.references :author
          end
          create_table :authors, force: true do |t|
            t.string :name
          end
          create_table :comments, force: true do |t|
            t.text :contents
            t.references :author
            t.references :post
          end
        end
      end
      class Post < ActiveRecord::Base
        has_many :comments
        belongs_to :author
      end
      class Comment < ActiveRecord::Base
        belongs_to :post
        belongs_to :author
      end
      class Author < ActiveRecord::Base
        has_many :posts
      end

      def with_adapter(adapter)
        old_adapter = ActiveModel::Serializer.config.adapter
        # JSON-API adapter sets root by default
        ActiveModel::Serializer.config.adapter = adapter
        yield
      ensure
        ActiveModel::Serializer.config.adapter = old_adapter
      end

      def test_json_api_deserialization_on_create
        author = Author.create(id: 1, name: "Author 1")
        Comment.create(id: 1, contents: "Comment 1", author: author)
        Comment.create(id: 2, contents: "Comment 2", author: author)
        payload = {
          data: {
            type: 'posts',
            attributes: {
              title: 'Title 1',
              body: 'Body 1'
            },
            relationships: {
              author: {
                data: { id: 1, type: 'authors'}
              },
              comments: {
                data: [{ id: 1, type: 'comments'},
                       { id: 2, type: 'comments'}]
              }
            }
          }
        }

        post = with_adapter :json_api do
          Post.create(PostSerializer.deserialize(ActionController::Parameters.new(payload)))
        end

        assert_equal('Title 1', post.title)
        assert_equal('Body 1', post.body)
        assert_equal(2, post.comments.count)
        assert_equal('Author 1', post.author.name)
      end
    end
  end
end
