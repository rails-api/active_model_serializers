require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class NestedJsonTest < Minitest::Test
        def setup
          ActionController::Base.cache_store.clear
          @author = Author.new(id: 1, name: 'Steve K.')
          @post = Post.new(id: 1, title: 'New Post', body: 'Body')
          @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
          @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')
          @post.comments = [@first_comment, @second_comment]
          @author.posts = [@post]

          @serializer = AuthorNestedSerializer.new(@author)
          @adapter = ActiveModel::Serializer::Adapter::Json.new(@serializer)
        end

        def test_has_many
          assert_equal({
            id: 1, name: 'Steve K.',
            posts: [{
              id: 1, title: 'New Post', body: 'Body',
              comments: [
                {id: 1, body: 'ZOMG A COMMENT'},
                {id: 2, body: 'ZOMG ANOTHER COMMENT'}
              ]
            }]
          }, @adapter.serializable_hash(limit_depth: 5)[:author])
        end

        def test_limit_depth
          assert_raises(StandardError) do
            @adapter.serializable_hash(limit_depth: 1, check_depth_strategy: :fail)
          end
        end

        def test_trim_strategy
          assert_equal({
            id: 1, name: 'Steve K.',
            posts: [{
              id: 1, title: 'New Post', body: 'Body',
            }]
          }, @adapter.serializable_hash(limit_depth: 1, check_depth_strategy: :trim)[:author])
        end

        def test_pass_strategy
          assert_equal({
            id: 1, name: 'Steve K.',
            posts: [{
              id: 1, title: 'New Post', body: 'Body',
              comments: [
                {id: 1, body: 'ZOMG A COMMENT'},
                {id: 2, body: 'ZOMG ANOTHER COMMENT'}
              ]
            }]
          }, @adapter.serializable_hash(limit_depth: 1, check_depth_strategy: :pass)[:author])
        end

        def test_flatten_json
          adapter = ActiveModel::Serializer::Adapter::FlattenJson.new(@serializer)
          assert_equal({
            id: 1, name: 'Steve K.',
            posts: [{
              id: 1, title: 'New Post', body: 'Body',
              comments: [
                {id: 1, body: 'ZOMG A COMMENT'},
                {id: 2, body: 'ZOMG ANOTHER COMMENT'}
              ]
            }]
          }, adapter.serializable_hash(limit_depth: 5))
        end
      end
    end
  end
end
