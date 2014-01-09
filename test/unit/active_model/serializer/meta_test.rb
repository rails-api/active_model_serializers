require 'test_helper'

module ActiveModel
  class Serializer
    class MetaTest < Minitest::Test
      def setup
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
      end

      def test_meta
        profile_serializer = ProfileSerializer.new(@profile, root: 'profile', meta: { total: 10 })

        assert_equal({
          'profile' => {
            name: 'Name 1',
            description: 'Description 1'
          },
          meta: {
            total: 10
          }
        }, profile_serializer.as_json)
      end

      def test_meta_using_meta_key
        profile_serializer = ProfileSerializer.new(@profile, root: 'profile', meta_key: :my_meta, my_meta: { total: 10 })

        assert_equal({
          'profile' => {
            name: 'Name 1',
            description: 'Description 1'
          },
          my_meta: {
            total: 10
          }
        }, profile_serializer.as_json)
      end
    end
  end
end
