require 'test_helper'

module ActiveModel
  class Serializer
    class AssocationsTest < Minitest::Test
      class Model
        def initialize(hash={})
          @attributes = hash
        end

        def read_attribute_for_serialization(name)
          @attributes[name]
        end

        def method_missing(meth, *args)
          if meth.to_s =~ /^(.*)=$/
            @attributes[$1.to_sym] = args[0]
          elsif @attributes.key?(meth)
            @attributes[meth]
          else
            super
          end
        end
      end


      def setup
        @post = Post.new({ title: 'New Post', body: 'Body' })
        @comment = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
        @post.comments = [@comment]
        @comment.post = @post

        @post_serializer = PostSerializer.new(@post)
        @comment_serializer = CommentSerializer.new(@comment)
      end

      def test_has_many
        assert_equal({comments: {type: :has_many, options: {}}}, @post_serializer.class._associations)
        assert_kind_of(ActiveModel::Serializer::ArraySerializer, @post_serializer.associations[:comments])
      end

      def test_has_one
        assert_equal({post: {type: :belongs_to, options: {}}}, @comment_serializer.class._associations)
        assert_kind_of(PostSerializer, @comment_serializer.associations[:post])
      end
    end
  end
end
