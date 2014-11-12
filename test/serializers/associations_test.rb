require 'test_helper'

module ActiveModel
  class Serializer
    class AssociationsTest < Minitest::Test
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
        @author = Author.new(name: 'Steve K.')
        @author.bio = nil
        @author.roles = []
        @post = Post.new({ title: 'New Post', body: 'Body' })
        @comment = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
        @post.comments = [@comment]
        @comment.post = @post
        @comment.author = nil
        @post.author = @author
        @author.posts = [@post]

        @author_serializer = AuthorSerializer.new(@author)
        @comment_serializer = CommentSerializer.new(@comment)
      end

      def test_has_many
        assert_equal(
          { posts: { type: :has_many, options: { embed: :ids } },
            roles: { type: :has_many, options: { embed: :ids } },
            bio: { type: :belongs_to, options: {} } },
          @author_serializer.class._associations
        )
        @author_serializer.each_association do |name, serializer, options|
          if name == :posts
            assert_equal({embed: :ids}, options)
            assert_kind_of(ActiveModel::Serializer.config.array_serializer, serializer)
          elsif name == :bio
            assert_equal({}, options)
            assert_nil serializer
          elsif name == :roles
            assert_equal({embed: :ids}, options)
            assert_kind_of(ActiveModel::Serializer.config.array_serializer, serializer)
          else
            flunk "Unknown association: #{name}"
          end
        end
      end

      def test_has_one
        assert_equal({post: {type: :belongs_to, options: {}}, :author=>{:type=>:belongs_to, :options=>{}}}, @comment_serializer.class._associations)
        @comment_serializer.each_association do |name, serializer, options|
          if name == :post
            assert_equal({}, options)
            assert_kind_of(PostSerializer, serializer)
          elsif name == :author
            assert_equal({}, options)
            assert_nil serializer
          else
            flunk "Unknown association: #{name}"
          end
        end
      end
    end
  end
end
