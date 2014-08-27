require 'test_helper'

module ActiveModel
  class Serializer
    class AssocationsTest < Minitest::Test
      def def_serializer(&block)
        Class.new(ActiveModel::Serializer, &block)
      end

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
        @post = Model.new({ title: 'New Post', body: 'Body' })
        @comment = Model.new({ id: 1, body: 'ZOMG A COMMENT' })
        @post.comments = [@comment]
        @comment.post = @post

        @post_serializer_class = def_serializer do
          attributes :title, :body
        end

        @comment_serializer_class = def_serializer do
          attributes :id, :body
        end

        @post_serializer = @post_serializer_class.new(@post)
        @comment_serializer = @comment_serializer_class.new(@comment)
      end

      def test_has_many
        @post_serializer_class.class_eval do
          has_many :comments
        end

        assert_equal({comments: {type: :has_many, options: {}}}, @post_serializer.class._associations)
      end

      def test_has_one
        @comment_serializer_class.class_eval do
          belongs_to :post
        end

        assert_equal({post: {type: :belongs_to, options: {}}}, @comment_serializer.class._associations)
      end

      def test_associations
        @comment_serializer_class.class_eval do
          belongs_to :post
          has_many :comments
        end

        expected_associations = {
          post: {
            type: :belongs_to,
            options: {}
          },
          comments: {
            type: :has_many,
            options: {}
          },
        }
        assert_equal(expected_associations, @comment_serializer.associations)
      end
    end
  end
end
