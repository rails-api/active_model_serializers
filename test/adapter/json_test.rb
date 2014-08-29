require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonAdapterTest < Minitest::Test
        def setup
          @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
          @profile_serializer = ProfileSerializer.new(@profile)

          @adapter = Json.new(@profile_serializer)
        end

        def test_serializable_hash
          assert_equal({name: 'Name 1', description: 'Description 1'}, @adapter.serializable_hash)
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

