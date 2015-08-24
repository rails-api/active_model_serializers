require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class ResourceTypeConfigTest < Minitest::Test
          def setup
            @author = Author.new(id: 1, name: 'Steve K.')
            @author.bio = nil
            @author.roles = []
            @blog = Blog.new(id: 23, name: 'AMS Blog')
            @post = Post.new(id: 42, title: 'New Post', body: 'Body')
            @anonymous_post = Post.new(id: 43, title: 'Hello!!', body: 'Hello, world!!')
            @comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @post.comments = [@comment]
            @post.blog = @blog
            @anonymous_post.comments = []
            @anonymous_post.blog = nil
            @comment.post = @post
            @comment.author = nil
            @post.author = @author
            @anonymous_post.author = nil
            @blog = Blog.new(id: 1, name: "My Blog!!")
            @blog.writer = @author
            @blog.articles = [@post, @anonymous_post]
            @author.posts = []
          end

          def with_jsonapi_resource_type type
            old_type = ActiveModel::Serializer.config[:jsonapi_resource_type]
            ActiveModel::Serializer.config[:jsonapi_resource_type] = type
            yield
          ensure
            ActiveModel::Serializer.config[:jsonapi_resource_type] = old_type
          end

          def test_config_plural
            with_jsonapi_resource_type :plural do
              serializer = CommentSerializer.new(@comment)
              adapter = ActiveModel::Serializer::Adapter::JsonApi.new(serializer)
              ActionController::Base.cache_store.clear
              assert_equal('comments', adapter.serializable_hash[:data][:type])
            end
          end

          def test_config_singular
            with_jsonapi_resource_type :singular do
              serializer = CommentSerializer.new(@comment)
              adapter = ActiveModel::Serializer::Adapter::JsonApi.new(serializer)
              ActionController::Base.cache_store.clear
              assert_equal('comment', adapter.serializable_hash[:data][:type])
            end
          end
        end
      end
    end
  end
end
