require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class FieldsetTest < Minitest::Test
          def setup
            @post = Post.new(title: 'New Post', body: 'Body')
            @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')
            @post.comments = [@first_comment, @second_comment]
            @first_comment.post = @post
            @second_comment.post = @post

            @serializer = PostSerializer.new(@post)
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer)
          end

          def teardown
            @serializer = nil
            @adapter = nil
          end

          def test_fieldset_with_fields_array
            fieldset = ActiveModel::Serializer::Fieldset.new(@serializer, ['title'])

            assert_equal(
              {:title=>"New Post", :links=>{:comments=>["1", "2"]}}, 
              @adapter.serializable_hash({fieldset: fieldset})[:posts]
            )
          end

          def test_fieldset_with_hash
            fieldset = ActiveModel::Serializer::Fieldset.new(@serializer, {post: [:body]})

            assert_equal(
              {:body=>"Body", :links=>{:comments=>["1", "2"]}}, 
              @adapter.serializable_hash({fieldset: fieldset})[:posts]
            )
          end

          def test_fieldset_with_multiple_hashes
            fieldset = ActiveModel::Serializer::Fieldset.new(@serializer, {post: [:title], comment: [:body]})

            assert_equal(
              [{:body=>"ZOMG A COMMENT" }, {:body=>"ZOMG ANOTHER COMMENT"}],
              @adapter.serializable_hash({fieldset: fieldset})[:linked][:comments]
            )
          end

        end
      end
    end
  end
end