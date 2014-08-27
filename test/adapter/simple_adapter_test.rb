require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class SimpleAdapterTest < Minitest::Test
        def setup
          @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
          @profile_serializer = ProfileSerializer.new(@profile)

          @adapter = SimpleAdapter.new(@profile_serializer)
        end

        def test_simple_adapter
          assert_equal('{"name":"Name 1","description":"Description 1"}',
                       @adapter.to_json)

JSON
        end
      end
    end
  end
end

