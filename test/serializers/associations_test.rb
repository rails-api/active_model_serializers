require 'test_helper'

module ActiveModel
  class Serializer
    class AssociationsTest < Minitest::Test
      Post    = Class.new(::Model)
      Author  = Class.new(::Model)
      Tag     = Class.new(::Model)
      Comment = Class.new(::Model)
      Blog    = Class.new(::Model)

      class PostSerializer < ActiveModel::Serializer
        attributes :id, :title, :body

        has_many :comments
        belongs_to :blog
        belongs_to :author
      end

      class PostWithTagsSerializer < ActiveModel::Serializer
        attributes :id

        has_many :tags
      end

      class PostWithCustomKeysSerializer < ActiveModel::Serializer
        attributes :id

        has_many :comments, key: :reviews
        belongs_to :author, key: :writer
        has_one :blog, key: :site
      end

      class AuthorSerializer < ActiveModel::Serializer
        attributes :id, :name
        has_many :posts
        has_many :roles
        has_one :bio
      end

      class CommentSerializer < ActiveModel::Serializer
        attributes :id, :body

        def custom_options
          instance_options
        end
      end

      def setup
        @author = Author.new(name: 'Steve K.')
        @author.bio = nil
        @author.roles = []
        @blog = Blog.new(name: 'AMS Blog')
        @post = Post.new(title: 'New Post', body: 'Body')
        @tag = Tag.new(name: '#hashtagged')
        @comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
        @post.comments = [@comment]
        @post.tags = [@tag]
        @post.blog = @blog
        @comment.post = @post
        @comment.author = nil
        @post.author = @author
        @author.posts = [@post]

        @post_serializer = PostSerializer.new(@post, custom_options: true)
        @author_serializer = AuthorSerializer.new(@author)
        @comment_serializer = CommentSerializer.new(@comment)
      end

      def test_has_many_and_has_one
        @author_serializer.associations.each do |association|
          key = association.key
          serializer = association.serializer
          options = association.options

          case key
          when :posts
            assert_equal({}, options)
            assert_kind_of(ActiveModel::Serializer.config.array_serializer, serializer)
          when :bio
            assert_equal({}, options)
            assert_nil serializer
          when :roles
            assert_equal({}, options)
            assert_kind_of(ActiveModel::Serializer.config.array_serializer, serializer)
          else
            flunk "Unknown association: #{key}"
          end
        end
      end

      def test_has_many_with_no_serializer
        PostWithTagsSerializer.new(@post).associations.each do |association|
          key = association.key
          serializer = association.serializer
          options = association.options

          assert_equal(key, :tags)
          assert_nil(serializer)

          expected = [{ attributes: { name: '#hashtagged' } }].to_json
          actual = options[:virtual_value].to_json
          assert_equal(expected, actual)
        end
      end

      def test_serializer_options_are_passed_into_associations_serializers
        association = @post_serializer
                        .associations
                        .detect { |assoc| assoc.key == :comments }

        assert(association.serializer.first.custom_options[:custom_options])
      end

      def test_belongs_to
        @comment_serializer.associations.each do |association|
          key = association.key
          serializer = association.serializer

          case key
          when :post
            assert_kind_of(PostSerializer, serializer)
          when :author
            assert_nil serializer
          else
            flunk "Unknown association: #{key}"
          end

          assert_equal({}, association.options)
        end
      end

      def test_belongs_to_with_custom_method
        assert(
          @post_serializer.associations.any? do |association|
            association.key == :blog
          end
        )
      end

      def test_associations_inheritance
        inherited_klass = Class.new(PostSerializer)

        assert_equal(PostSerializer._reflections, inherited_klass._reflections)
      end

      def test_associations_inheritance_with_new_association
        inherited_klass = Class.new(PostSerializer) do
          has_many :top_comments, serializer: CommentSerializer
        end

        assert(
          PostSerializer._reflections.all? do |reflection|
            inherited_klass._reflections.include?(reflection)
          end
        )

        assert(
          inherited_klass._reflections.any? do |reflection|
            reflection.name == :top_comments
          end
        )
      end

      def test_associations_custom_keys
        serializer = PostWithCustomKeysSerializer.new(@post)

        expected_association_keys = serializer.associations.map(&:key)

        assert_includes(expected_association_keys, :reviews)
        assert_includes(expected_association_keys, :writer)
        assert_includes(expected_association_keys, :site)
      end
    end
  end
end
