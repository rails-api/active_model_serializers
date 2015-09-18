require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApiTest < Minitest::Test
        def setup
          ActionController::Base.cache_store.clear
          @author = Author.new(id: 1, name: 'Steve K.')
          @post = Post.new(id: 1, title: 'New Post', body: 'Body')
          @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
          @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')
          @post.comments = [@first_comment, @second_comment]
          @first_comment.post = @post
          @second_comment.post = @post
          @post.author = @author
          @blog = Blog.new(id: 1, name: 'My Blog!!')
          @post.blog = @blog
        end

        def test_custom_keys
          serializer = PostWithCustomKeysSerializer.new(@post)
          adapter = ActiveModel::Serializer::Adapter::JsonApi.new(serializer)

          assert_equal({
            reviews: { data: [
                        { type: 'comments', id: '1' },
                        { type: 'comments', id: '2' }
                    ] },
            writer: { data: { type: 'authors', id: '1' } },
            site: { data: { type: 'blogs', id: '1' } }
            }, adapter.serializable_hash[:data][:relationships])
        end

        def test_override_type
          post_override_serializer = Class.new(PostSerializer) do
            def type
              'override'
            end
          end
          hash = ActiveModel::SerializableResource.new(@post, adapter: :json_api, serializer: post_override_serializer).serializable_hash

          assert_equal('override', hash[:data][:type])
        end
      end
    end
  end
end