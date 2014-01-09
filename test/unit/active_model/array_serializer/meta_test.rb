require 'test_helper'
require 'active_model/serializer'

module ActiveModel
  class ArraySerializer
    class MetaTest < Minitest::Test
      def setup
        @profile1 = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @profile2 = Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })
        @serializer = ArraySerializer.new([@profile1, @profile2], root: 'profiles')
      end

      def test_meta
        @serializer.meta = { total: 10 }

        assert_equal({
          'profiles' => [
            {
              name: 'Name 1',
              description: 'Description 1'
            }, {
              name: 'Name 2',
              description: 'Description 2'
            }
          ],
          meta: {
            total: 10
          }
        }, @serializer.as_json)
      end

      def test_meta_using_meta_key
        @serializer.meta_key = :my_meta
        @serializer.meta     = { total: 10 }

        assert_equal({
          'profiles' => [
            {
              name: 'Name 1',
              description: 'Description 1'
            }, {
              name: 'Name 2',
              description: 'Description 2'
            }
          ],
          my_meta: {
            total: 10
          }
        }, @serializer.as_json)
      end
    end
  end
end
