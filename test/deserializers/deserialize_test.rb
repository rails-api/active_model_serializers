require 'test_helper'

module ActiveModel
  class Serializer
    class DeserializeTest < Minitest::Test
      def with_adapter(adapter)
        old_adapter = ActiveModel::Serializer.config.adapter
        # JSON-API adapter sets root by default
        ActiveModel::Serializer.config.adapter = adapter
        yield
      ensure
        ActiveModel::Serializer.config.adapter = old_adapter
      end

      def test_json_api_deserialize_on_create
        author = ARModels::Author.create(name: "Author 1")
        comment1 = ARModels::Comment.create(contents: "Comment 1", author: author)
        comment2 = ARModels::Comment.create(contents: "Comment 2", author: author)
        payload = {
          data: {
            type: 'posts',
            attributes: {
              title: 'Title 1',
              body: 'Body 1'
            },
            relationships: {
              author: {
                data: { id: author.id, type: 'authors'}
              },
              comments: {
                data: [{ id: comment1.id, type: 'comments'},
                       { id: comment2.id, type: 'comments'}]
              }
            }
          }
        }

        post = with_adapter :json_api do
          ARModels::Post.create(ARModels::PostSerializer.deserialize(ActionController::Parameters.new(payload)))
        end

        assert_equal('Title 1', post.title)
        assert_equal('Body 1', post.body)
        assert_equal(2, post.comments.count)
        assert_equal('Author 1', post.author.name)
      end
    end
  end
end
