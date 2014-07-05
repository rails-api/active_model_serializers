require 'test_helper'

module ActiveModel
  class Serializer
    class FilterOptionsTest < Minitest::Test
      def setup
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @desk = Desk.new({ drawer: 'My drawer', lamp: 'My lamp', secret_document: 'Some secret document' })
      end

      def test_only_option
        @profile_serializer = ProfileSerializer.new(@profile, only: :name)
        assert_equal({
          'profile' => { name: 'Name 1' }
        }, @profile_serializer.as_json)
      end

      def test_except_option
        @profile_serializer = ProfileSerializer.new(@profile, except: :comments)
        assert_equal({
          'profile' => { name: 'Name 1', description: 'Description 1' }
        }, @profile_serializer.as_json)
      end

      def test_not_expose_hidden_attribute
        desk_serializer = DeskSerializer.new(@desk)
        assert_equal({
          'desk' => { drawer: 'My drawer', lamp: 'My lamp' }
        }, desk_serializer.as_json)
      end

      def test_expose_hidden_attribute
        desk_serializer = DeskSerializer.new(@desk, expose: :secret_document)
        assert_equal({
          'desk' => { drawer: 'My drawer', lamp: 'My lamp', secret_document: 'Some secret document' }
        }, desk_serializer.as_json)
      end
    end

    class FilterAttributesTest < Minitest::Test
      def setup
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @profile_serializer = ProfileSerializer.new(@profile)
        @profile_serializer.instance_eval do
          def filter(keys)
            keys - [:description]
          end
        end
      end

      def test_filtered_attributes_serialization
        assert_equal({
          'profile' => { name: 'Name 1' }
        }, @profile_serializer.as_json)
      end
    end

    class FilterAssociationsTest < Minitest::Test
      def setup
        @association = PostSerializer._associations[:comments]
        @old_association = @association.dup
        @association.embed = :ids
        @association.embed_in_root = true
        @post = Post.new({ title: 'Title 1', body: 'Body 1', date: '1/1/2000' })
        @post_serializer = PostSerializer.new(@post)
        @post_serializer.instance_eval do
          def filter(keys)
            keys - [:body, :comments]
          end
        end
      end

      def teardown
        PostSerializer._associations[:comments] = @old_association
      end

      def test_filtered_associations_serialization
        assert_equal({
          'post' => { title: 'Title 1' }
        }, @post_serializer.as_json)
      end
    end
  end
end
