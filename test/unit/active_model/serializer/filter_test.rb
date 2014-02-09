require 'test_helper'

module ActiveModel
  class Serializer
    class FilterOptionsTest < Minitest::Test
      def setup
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
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
