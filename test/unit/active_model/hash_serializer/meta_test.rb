require 'test_helper'
require 'active_model/serializer'

module ActiveModel
  class HashSerializer
    class MetaTest < ActiveModel::TestCase
      def setup
        @profile1 = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @profile2 = Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })
        @serializer = HashSerializer.new({profile1: @profile1, profile2: @profile2}, root: 'profiles')
      end

      def test_meta
        @serializer.meta = { total: 10 }

        assert_equal({
          "profiles" => {
            profile1:
              {
                name: 'Name 1',
                description: 'Description 1'
              },
            profile2:
              {
                name: 'Name 2',
                description: 'Description 2'
              }
          },
          meta: {
            total: 10
          }
        }, @serializer.as_json)
      end

      def test_meta_using_meta_key
        @serializer.meta_key = :my_meta
        @serializer.meta     = { total: 10 }

        assert_equal({
           "profiles" => {
             profile1:
               {
                 name: 'Name 1',
                 description: 'Description 1'
               },
             profile2:
               {
                 name: 'Name 2',
                 description: 'Description 2'
               }
           },
           my_meta: {
             total: 10
           }
         }, @serializer.as_json)
      end
    end
  end
end
