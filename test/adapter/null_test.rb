require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class NullTest < Minitest::Test
        def setup
          profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
          serializer = ProfileSerialization.new(profile)

          @adapter = Null.new(serializer)
        end

        def test_serializable_hash
          assert_equal({}, @adapter.serializable_hash)
        end

        def test_it_returns_empty_json
          assert_equal('{}', @adapter.to_json)
        end
      end
    end
  end
end

