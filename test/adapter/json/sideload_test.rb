require 'test_helper'

class ParentBlog < Blog; end
class ParentBlogSerializer < BlogSerializer; end
class HasOnePostSerializer < PostSerializer
  attributes :id, :title, :body

  has_many :comments
  belongs_to :blog
  belongs_to :author
  has_one :parent_blog
  url :comments
end

module ActiveModel
  class Serializer
    class Adapter
      class Json
        class SideloadTestTest < Minitest::Test
          def setup
            ActiveModel::Serializer.config.sideload_associations = true
            ActionController::Base.cache_store.clear
            @author = Author.new(id: 1, name: 'Steve K.')
            @post = Post.new(id: 42, title: 'New Post', body: 'Body')
            @first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')
            @post.comments = [@first_comment, @second_comment]
            @post.author = @author
            @first_comment.post = @post
            @second_comment.post = @post
            @blog = Blog.new(id: 1, name: "My Blog!!")
            @parent_blog = ParentBlog.new(id: 2, name: "Parent Blog!!")
            @post.blog = @blog
            @post.parent_blog = @parent_blog
            @tag = Tag.new(id: 1, name: "#hash_tag")
            @post.tags = [@tag]
          end

          def teardown
            ActiveModel::Serializer.config.sideload_associations = false
          end

          def test_associations_not_present_in_base_model
            serializer = PostSerializer.new(@post)
            adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)
            assert_equal(nil, adapter.serializable_hash[:post][:comments])
          end

          def test_associations_replaced_with_association_ids
            serializer = PostSerializer.new(@post)
            adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)
            assert_equal([1, 2], adapter.serializable_hash[:post][:comment_ids])
          end

          def test_relevant_associated_objects_in_json_root
            serializer = PostSerializer.new(@post)
            adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)
            assert_equal([
                           {id: 1, body: 'ZOMG A COMMENT'},
                           {id: 2, body: 'ZOMG ANOTHER COMMENT'}
                         ], adapter.serializable_hash[:comments])
          end

          def test_has_one_has_a_singular_key
            serializer = HasOnePostSerializer.new(@post)
            adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)

            assert_equal({
                id: 2, name: "Parent Blog!!"
              }, adapter.serializable_hash[:parent_blog])
          end

          def test_belongs_to_has_a_singular_key
            serializer = PostSerializer.new(@post)
            adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)

            assert_equal({
                id: 1, name: "Steve K."
              }, adapter.serializable_hash[:author])

          end
        end
      end
    end
  end
end
