require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class FieldsetTest < Minitest::Test
          def setup
            @post = Post.new(title: 'New Post', body: 'Body')
            comment_1 = Comment.new(id: 1, body: 'comment one')
            comment_2 = Comment.new(id: 2, body: 'comment two')
            @post.comments = [comment_1, comment_2]

            @serializer = PostSerializer.new(@post)
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer)

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
              [{:body=>"comment one" }, {:body=>"comment two"}],
              @adapter.serializable_hash({fieldset: fieldset})[:linked][:comments]
            )

            #don't understand how this is getting set.
            @serializer.class._associations[:comments][:options] = {}

          end

        end
      end
    end
  end
end