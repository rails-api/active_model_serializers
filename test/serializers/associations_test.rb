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
        @tag = Tag.new({name: '#hashtagged'})
        @comment = Comment.new({ id: 1, body: 'ZOMG A COMMENT' })
        @post.comments = [@comment]
        @post.tags = [@tag]
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
        @author_serializer.associations.each do |association|
          key = association.key
          serializer = association.serializer
          options = association.options

          case key
          when :posts
            assert_equal({ embed: :ids }, options)
            assert_kind_of(ActiveModel::Serializer.config.array_serializer, serializer)
          when :bio
            assert_equal({}, options)
            assert_nil serializer
          when :roles
            assert_equal({ embed: :ids }, options)
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

          assert_equal key, :tags
          assert_equal serializer, nil
          assert_equal [{ attributes: { name: "#hashtagged" }}].to_json, options[:virtual_value].to_json
        end
      end

      def test_serializer_options_are_passed_into_associations_serializers
        association = @post_serializer
                        .associations
                        .detect { |assoc| assoc.key == :comments }

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
    end
  end
end
