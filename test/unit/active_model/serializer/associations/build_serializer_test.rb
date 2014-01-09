require 'test_helper'

module ActiveModel
  class Serializer
    class Association
      class BuildSerializerTest < Minitest::Test
        def setup
          @association = Association::HasOne.new('post', serializer: PostSerializer)
          @post = Post.new({ title: 'Title 1', body: 'Body 1', date: '1/1/2000' })
        end

        def test_build_serializer_for_array_called_twice
          2.times do
            serializer = @association.build_serializer(@post)
            assert_instance_of(PostSerializer, serializer)
          end
        end
      end
    end
  end
end
