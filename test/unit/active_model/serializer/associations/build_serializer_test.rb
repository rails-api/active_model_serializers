require 'test_helper'

module ActiveModel
  class Serializer
    class Association
      class BuildSerializerTest < Minitest::Test
        def setup
          @association = Association::HasOne.new('post', serializer: PostSerializer)
          @post = Post.new({ title: 'Title 1', body: 'Body 1', date: '1/1/2000' })
          @user = User.new
        end

        def test_build_serializer_for_array_called_twice
          2.times do
            serializer = @association.build_serializer(@post)
            assert_instance_of(PostSerializer, serializer)
          end
        end

        def test_build_serializer_from_in_a_namespace
          assoc      = Association::HasOne.new('profile')
          serializer = TestNamespace::UserSerializer.new(@user).build_serializer(assoc)

          assert_instance_of(TestNamespace::ProfileSerializer, serializer)
        end

        def test_build_serializer_with_prefix
          assoc      = Association::HasOne.new('profile', prefix: :short)
          serializer = UserSerializer.new(@user).build_serializer(assoc)

          assert_instance_of(ShortProfileSerializer, serializer)
        end
      end
    end
  end
end
