require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class FlatJson
        class FlatJsonTest < Minitest::Test
          class ParentBlog < Blog; end
          class ParentBlogSerializer < BlogSerializer; end
          class HasOnePostSerializer < PostSerializer
            attributes :id, :title, :body

            has_many :comments
            belongs_to :blog
            belongs_to :author
            has_one :parent_blog
          end

          class IdsSerializer < ActiveModel::Serializer
            attributes :id, :title, :comment_ids

            undef :comment_ids
            def comment_ids
              object.comments.collect(&:id)
            end
          end

          def setup
            # ActiveModel::Serializer.config.sideload_associations = true
            ActionController::Base.cache_store.clear
            @author = Author.new(id: 1, name: 'Steve K.')
            @post = Post.new(id: 42, title: 'New Post', body: 'Body')
            @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT', author: @author)
            @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT', author: @author)
            @post.comments = [@first_comment, @second_comment]
            @post.author = @author
            @first_comment.post = @post
            @second_comment.post = @post
            @blog = Blog.new(id: 1, name: 'My Blog!!')
            @parent_blog = ParentBlog.new(id: 2, name: 'Parent Blog!!')
            @post.blog = @blog
            @post.parent_blog = @parent_blog
            @tag = Tag.new(id: 1, name: '#hash_tag')
            @post.tags = [@tag]
          end

          def teardown
            # ActiveModel::Serializer.config.sideload_associations = false
          end

          def test_comment_ids
            serializable = SerializableResource.new(@post, adapter: FlatJson, serializer: IdsSerializer)
            expected = {
              post: { id: 42, title: 'New Post', comment_ids: [1, 2] }
            }
            actual = serializable.serializable_hash

            assert_equal expected, actual
          end

          def test_associations_not_present_in_base_model
            serializable = SerializableResource.new(@post, adapter: FlatJson)

            assert_equal(nil, serializable.serializable_hash[:post][:comments])
          end

          def test_associations_replaced_with_association_ids
            serializable = SerializableResource.new(@post, adapter: FlatJson)

            assert_equal([1, 2], serializable.serializable_hash[:post][:comment_ids])
          end

          def test_relevant_associated_objects_in_json_root
            serializable = SerializableResource.new(@post, adapter: FlatJson)

            expected = {
              comments: [
                { :id => 1, :body => 'ZOMG A COMMENT' },
                { :id => 2, :body => 'ZOMG ANOTHER COMMENT' }
              ],
              blog: {
                id: 999,
                name: 'Custom blog'
              },
              author: {
                id: 1,
                name: 'Steve K.'
              },
              post: {
                id: 42,
                title: 'New Post',
                body: 'Body',
                comment_ids: [1, 2],
                author_id: 1,
                blog_id: 999
              }
             }
            actual = serializable.serializable_hash

            assert_equal(expected, actual)
          end

          def test_has_one_has_a_singular_key
            serializable = SerializableResource.new(@post,
              adapter: FlatJson,
              serializer: HasOnePostSerializer)

            expected = {
              id: 2, name: 'Parent Blog!!'
            }

            assert_equal(expected, serializable.serializable_hash[:parent_blog])
          end

          def test_belongs_to_has_a_singular_key
            serializable = SerializableResource.new(@post, adapter: FlatJson)

            assert_equal({
                id: 1, name: 'Steve K.'
              }, serializable.serializable_hash[:author])
          end
        end
      end
    end
  end
end
