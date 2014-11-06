require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class HasOneTest < Minitest::Test
          def setup
            @author = Author.new(id: 1, name: 'Steve K.')
            @bio = Bio.new(id: 43, content: 'AMS Contributor')
            @author.bio = @bio
            @bio.author = @author
            @post = Post.new(id: 42, title: 'New Post', body: 'Body')
            @anonymous_post = Post.new(id: 43, title: 'Hello!!', body: 'Hello, world!!')
            @comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
            @post.comments = [@comment]
            @anonymous_post.comments = []
            @comment.post = @post
            @comment.author = nil
            @post.author = @author
            @anonymous_post.author = nil
            @blog = Blog.new(id: 1, name: "My Blog!!")
            @blog.writer = @author
            @blog.articles = [@post, @anonymous_post]
            @author.posts = []
            @author.roles = []

            @serializer = AuthorSerializer.new(@author)
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer, include: 'bio,posts')
          end

          def test_includes_bio_id
            assert_equal("43", @adapter.serializable_hash[:authors][:links][:bio])
          end

          def test_includes_linked_bio
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer, include: 'bio')
            assert_equal([{id: "43", :content=>"AMS Contributor", :links=>{:author=>"1"}}], @adapter.serializable_hash[:linked][:bios])
          end
        end
      end
    end
  end
end
