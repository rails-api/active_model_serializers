require 'test_helper'

module ActiveModel
  class Serializer
    class AssociationsTest < ActiveSupport::TestCase
      def setup
        @author = Author.new(name: 'Steve K.')
        @author.bio = nil
        @author.roles = []
        @blog = Blog.new({ name: 'AMS Blog' })
        @post = Post.new({ title: 'New Post', body: 'Body' })
        @tag = Tag.new({ name: '#hashtagged' })
        @comment = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
        @post.comments = [@comment]
        @post.tags = [@tag]
        @post.blog = @blog
        @comment.post = @post
        @comment.author = nil
        @post.author = @author
        @author.posts = [@post]

        @post_serializer = PostSerializer.new(@post, { custom_options: true })
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
            assert_kind_of(ActiveModelSerializers.config.collection_serializer, serializer)
          when :bio
            assert_equal({}, options)
            assert_nil serializer
          when :roles
            assert_equal({}, options)
            assert_kind_of(ActiveModelSerializers.config.collection_serializer, serializer)
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

          assert_equal :tags, key
          assert_nil serializer
          assert_equal [{ name: '#hashtagged' }].to_json, options[:virtual_value].to_json
        end
      end

      def test_serializer_options_are_passed_into_associations_serializers
        association = @post_serializer.
                      associations.
                      detect { |assoc| assoc.key == :comments }

        assert association.serializer.first.custom_options[:custom_options]
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

        assert expected_association_keys.include? :reviews
        assert expected_association_keys.include? :writer
        assert expected_association_keys.include? :site
      end

      class InlineAssociationTestPostSerializer < ActiveModel::Serializer
        has_many :comments
        has_many :comments, key: :last_comments do
          object.comments.last(1)
        end
      end

      def test_virtual_attribute_block
        comment1 = ::ARModels::Comment.create!(contents: 'first comment')
        comment2 = ::ARModels::Comment.create!(contents: 'last comment')
        post = ::ARModels::Post.create!(
          title: 'inline association test',
          body: 'etc',
          comments: [comment1, comment2]
        )
        actual = serializable(post, adapter: :attributes, serializer: InlineAssociationTestPostSerializer).as_json
        expected = {
          :comments => [
            { :id => 1, :contents => 'first comment' },
            { :id => 2, :contents => 'last comment' },
          ],
          :last_comments => [
            { :id => 2, :contents => 'last comment' },
          ],
        }

        assert_equal expected, actual
      ensure
        ::ARModels::Post.delete_all
        ::ARModels::Comment.delete_all
      end

      class NamespacedResourcesTest < ActiveSupport::TestCase
        class ResourceNamespace
          Post    = Class.new(::Model)
          Comment = Class.new(::Model)
          Author  = Class.new(::Model)
          Description = Class.new(::Model)
          class PostSerializer < ActiveModel::Serializer
            has_many :comments
            belongs_to :author
            has_one :description
          end
          CommentSerializer     = Class.new(ActiveModel::Serializer)
          AuthorSerializer      = Class.new(ActiveModel::Serializer)
          DescriptionSerializer = Class.new(ActiveModel::Serializer)
        end

        def setup
          @comment = ResourceNamespace::Comment.new
          @author = ResourceNamespace::Author.new
          @description = ResourceNamespace::Description.new
          @post = ResourceNamespace::Post.new(comments: [@comment],
                                              author: @author,
                                              description: @description)
          @post_serializer = ResourceNamespace::PostSerializer.new(@post)
        end

        def test_associations_namespaced_resources
          @post_serializer.associations.each do |association|
            case association.key
            when :comments
              assert_instance_of(ResourceNamespace::CommentSerializer, association.serializer.first)
            when :author
              assert_instance_of(ResourceNamespace::AuthorSerializer, association.serializer)
            when :description
              assert_instance_of(ResourceNamespace::DescriptionSerializer, association.serializer)
            else
              flunk "Unknown association: #{key}"
            end
          end
        end
      end

      class NestedSerializersTest < ActiveSupport::TestCase
        Post    = Class.new(::Model)
        Comment = Class.new(::Model)
        Author  = Class.new(::Model)
        Description = Class.new(::Model)
        class PostSerializer < ActiveModel::Serializer
          has_many :comments
          CommentSerializer = Class.new(ActiveModel::Serializer)
          belongs_to :author
          AuthorSerializer = Class.new(ActiveModel::Serializer)
          has_one :description
          DescriptionSerializer = Class.new(ActiveModel::Serializer)
        end

        def setup
          @comment = Comment.new
          @author = Author.new
          @description = Description.new
          @post = Post.new(comments: [@comment],
                           author: @author,
                           description: @description)
          @post_serializer = PostSerializer.new(@post)
        end

        def test_associations_namespaced_resources
          @post_serializer.associations.each do |association|
            case association.key
            when :comments
              assert_instance_of(PostSerializer::CommentSerializer, association.serializer.first)
            when :author
              assert_instance_of(PostSerializer::AuthorSerializer, association.serializer)
            when :description
              assert_instance_of(PostSerializer::DescriptionSerializer, association.serializer)
            else
              flunk "Unknown association: #{key}"
            end
          end
        end

        def test_conditional_associations
          serializer = Class.new(ActiveModel::Serializer) do
            belongs_to :if_assoc_included, if: :true
            belongs_to :if_assoc_excluded, if: :false
            belongs_to :unless_assoc_included, unless: :false
            belongs_to :unless_assoc_excluded, unless: :true

            def true
              true
            end

            def false
              false
            end
          end

          model = ::Model.new
          hash = serializable(model, serializer: serializer).serializable_hash
          expected = { if_assoc_included: nil, unless_assoc_included: nil }

          assert_equal(expected, hash)
        end
      end
    end
  end
end
