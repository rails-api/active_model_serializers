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
        @post_serializer.each_association do |name, serializer, options|
          assert_equal(:comments, name)
          assert_equal({}, options)
          assert_kind_of(ActiveModel::Serializer.config.array_serializer, serializer)
        end
      end

      def test_has_one
        assert_equal({post: {type: :belongs_to, options: {}}}, @comment_serializer.class._associations)
        @comment_serializer.each_association do |name, serializer, options|
          assert_equal(:post, name)
          assert_equal({}, options)
          assert_kind_of(PostSerializer, serializer)
        end
      end
    end
  end
end
