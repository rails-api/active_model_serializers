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
        @blog = Blog.new({ name: 'AMS Blog' })
        @post = Post.new({ title: 'New Post', body: 'Body' })
        @comment = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
        @post.comments = [@comment]
        @post.blog = @blog
        @comment.post = @post
        @comment.author = nil
        @post.author = @author
        @author.posts = [@post]

        @post_serializer = PostSerializer.new(@post, {custom_options: true})
        @author_serializer = AuthorSerializer.new(@author)
        @comment_serializer = CommentSerializer.new(@comment)
      end

      def test_has_many_and_has_one
        assert_equal(
          { posts: { type: :has_many, association_options: { embed: :ids } },
            roles: { type: :has_many, association_options: { embed: :ids } },
            bio: { type: :has_one, association_options: {} } },
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

      def test_serializer_options_are_passed_into_associations_serializers
        @post_serializer.each_association do |name, association|
          if name == :comments
            assert association.first.custom_options[:custom_options]
          end
        end
      end

      def test_belongs_to
        assert_equal(
          { post: { type: :belongs_to, association_options: {} },
            author: { type: :belongs_to, association_options: {} } },
          @comment_serializer.class._associations
        )
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

      def test_belongs_to_with_custom_method
        blog_is_present = false

        @post_serializer.each_association do |name, serializer, options|
          blog_is_present = true if name == :blog
        end

        assert blog_is_present
      end

      def test_associations_inheritance
        inherited_klass = Class.new(PostSerializer)

        assert_equal(PostSerializer._associations, inherited_klass._associations)
      end

      def test_associations_inheritance_with_new_association
        inherited_klass = Class.new(PostSerializer) do
          has_many :top_comments, serializer: CommentSerializer
        end
        expected_associations = PostSerializer._associations.merge(
          top_comments: {
            type: :has_many,
            association_options: {
              serializer: CommentSerializer
            }
          }
        )
        assert_equal(inherited_klass._associations, expected_associations)
      end
    end
  end
end
