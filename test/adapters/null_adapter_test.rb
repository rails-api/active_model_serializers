require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class NullAdapterTest < Minitest::Test
        def setup
          @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
          @profile_serializer = ProfileSerializer.new(@profile)

          @adapter = NullAdapter.new(@profile_serializer)
        end

        def test_null_adapter
          assert_equal('{"name":"Name 1","description":"Description 1"}',
                       @adapter.to_json)

JSON
        end
      end
    end
  end
end

