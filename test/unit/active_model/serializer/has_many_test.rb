require 'test_helper'

module ActiveModel
  class Serializer
    class HasManyTest < Minitest::Test
      def setup
        @association = PostSerializer._associations[:comments]
        @old_association = @association.dup

        @post = Post.new({ title: 'Title 1', body: 'Body 1', date: '1/1/2000' })
        @post_serializer = PostSerializer.new(@post)
      end

      def teardown
        PostSerializer._associations[:comments] = @old_association
      end

      def test_associations_definition
        assert_equal 1, PostSerializer._associations.length
        assert_kind_of Association::HasMany, @association
        assert_equal 'comments', @association.name
      end

      def test_associations_inheritance
        inherited_serializer_klass = Class.new(PostSerializer) do
          has_many :some_associations
        end
        another_inherited_serializer_klass = Class.new(PostSerializer)

        assert_equal(PostSerializer._associations.length + 1,
          inherited_serializer_klass._associations.length)
        assert_equal(PostSerializer._associations.length,
          another_inherited_serializer_klass._associations.length)
      end

      def test_associations_embedding_ids_serialization_using_serializable_hash
        @association.embed = :ids

        assert_equal({
          title: 'Title 1', body: 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id }
        }, @post_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_serialization_using_as_json
        @association.embed = :ids

        assert_equal({
          'post' => { title: 'Title 1', body: 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id } }
        }, @post_serializer.as_json)
      end

      def test_associations_embedding_ids_serialization_using_serializable_hash_and_key_from_options
        @association.embed = :ids
        @association.key = 'key'

        assert_equal({
          title: 'Title 1', body: 'Body 1', 'key' => @post.comments.map { |c| c.object_id }
        }, @post_serializer.serializable_hash)
      end

      def test_associations_embedding_objects_serialization_using_serializable_hash
        @association.embed = :objects

        assert_equal({
          title: 'Title 1', body: 'Body 1', comments: [{ content: 'C1' }, { content: 'C2' }]
        }, @post_serializer.serializable_hash)
      end

      def test_associations_embedding_objects_serialization_using_as_json
        @association.embed = :objects

        assert_equal({
          'post' => { title: 'Title 1', body: 'Body 1', comments: [{ content: 'C1' }, { content: 'C2' }] }
        }, @post_serializer.as_json)
      end

      def test_associations_embedding_nil_objects_serialization_using_as_json
        @association.embed = :objects
        @post.instance_eval do
          def comments
            [nil]
          end
        end

        assert_equal({
          'post' => { title: 'Title 1', body: 'Body 1', comments: [nil] }
        }, @post_serializer.as_json)
      end

      def test_associations_embedding_objects_serialization_using_serializable_hash_and_root_from_options
        @association.embed = :objects
        @association.embedded_key = 'root'

        assert_equal({
          title: 'Title 1', body: 'Body 1', 'root' => [{ content: 'C1' }, { content: 'C2' }]
        }, @post_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_serializable_hash
        @association.embed = :ids
        @association.embed_in_root = true

        assert_equal({
          title: 'Title 1', body: 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id }
        }, @post_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_as_json
        @association.embed = :ids
        @association.embed_in_root = true

        assert_equal({
          'post' => { title: 'Title 1', body: 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id } },
          'comments' => [{ content: 'C1' }, { content: 'C2' }]
        }, @post_serializer.as_json)
      end

      def test_associations_embedding_ids_including_objects_serialization_when_invoked_from_parent_serializer
        @association.embed = :ids
        @association.embed_in_root = true

        category = Category.new(name: 'Name 1')
        category.instance_variable_set(:@posts, [@post])
        category_serializer = CategorySerializer.new(category)

        assert_equal({
          'category' => {
            name: 'Name 1',
            posts: [{ title: 'Title 1', body: 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id } }]
          },
          "comments" => [{ content: 'C1' }, { content: 'C2' }]
        }, category_serializer.as_json)
      end

      def test_associations_embedding_nothing_including_objects_serialization_using_as_json
        @association.embed = nil
        @association.embed_in_root = true

        assert_equal({
          'post' => { title: 'Title 1', body: 'Body 1' },
          'comments' => [{ content: 'C1' }, { content: 'C2' }]
        }, @post_serializer.as_json)
      end

      def test_associations_using_a_given_serializer
        @association.embed = :ids
        @association.embed_in_root = true
        @association.serializer_from_options = Class.new(Serializer) do
          def content
            object.read_attribute_for_serialization(:content) + '!'
          end

          attributes :content
        end

        assert_equal({
          'post' => { title: 'Title 1', body: 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id } },
          'comments' => [{ content: 'C1!' }, { content: 'C2!' }]
        }, @post_serializer.as_json)
      end

      def test_associations_embedding_ids_using_a_given_array_serializer
        @association.embed = :ids
        @association.embed_in_root = true
        @association.serializer_from_options = Class.new(ArraySerializer) do
          def serializable_object
            { my_content: ['fake'] }
          end
        end

        assert_equal({
          'post' => { title: 'Title 1', body: 'Body 1', 'comment_ids' => @post.comments.map { |c| c.object_id } },
          'comments' => { my_content: ['fake'] }
        }, @post_serializer.as_json)
      end

      def test_associations_embedding_objects_using_a_given_array_serializer
        @association.serializer_from_options = Class.new(ArraySerializer) do
          def serializable_object(options={})
            { my_content: ['fake'] }
          end
        end

        assert_equal({
          'post' => { title: 'Title 1', body: 'Body 1', comments: { my_content: ['fake'] } }
        }, @post_serializer.as_json)
      end

      def test_associations_embedding_ids_including_objects_serialization_with_embed_in_root_key
        @association.embed_in_root = true
        @association.embed_in_root_key = :linked
        @association.embed = :ids
        assert_equal({
          'post' => {
            title: 'Title 1', body: 'Body 1',
            'comment_ids' => @post.comments.map(&:object_id)
          },
          linked: {
            'comments' => [
              { content: 'C1' },
              { content: 'C2' }
            ]
          },
        }, @post_serializer.as_json)
      end

      def test_associations_embedding_ids_using_embed_namespace_including_object_serialization_with_embed_in_root_key
        @association.embed_in_root = true
        @association.embed_in_root_key = :linked
        @association.embed = :ids
        @association.embed_namespace = :links
        @association.key = :comments
        assert_equal({
          'post' => {
            title: 'Title 1', body: 'Body 1',
            links: {
              comments: @post.comments.map(&:object_id)
            }
          },
          linked: {
            'comments' => [
              { content: 'C1' },
              { content: 'C2' }
            ]
          },
        }, @post_serializer.as_json)
      end

      def test_associations_embedding_objects_using_embed_namespace
        @association.embed = :objects
        @association.embed_namespace = :links

        assert_equal({
          'post' => {
            title: 'Title 1', body: 'Body 1',
            links: {
              comments: [
                { content: 'C1' },
                { content: 'C2' }
              ]
            }
          }
        }, @post_serializer.as_json)
      end

      def test_associations_name_key_embedding_ids_serialization_using_serializable_hash
        @association = NameKeyPostSerializer._associations[:comments]
        @association.embed = :ids

        assert_equal({
          title: 'Title 1', body: 'Body 1', 'comments' => @post.comments.map { |c| c.object_id }
        }, NameKeyPostSerializer.new(@post).serializable_hash)
      end

      def test_associations_name_key_embedding_ids_serialization_using_as_json
        @association = NameKeyPostSerializer._associations[:comments]
        @association.embed = :ids

        assert_equal({
          'name_key_post' => { title: 'Title 1', body: 'Body 1', 'comments' => @post.comments.map { |c| c.object_id } }
        }, NameKeyPostSerializer.new(@post).as_json)
      end
    end
  end
end
