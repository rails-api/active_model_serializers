require 'test_helper'

module ActiveModel
  class HashSerializer
    class ScopeTest < ActiveModel::TestCase
      def test_hash_serializer_pass_options_to_items_serializers
        hash = {profile1: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' }),
                profile2: Profile.new({ name: 'Name 2', description: 'Description 2', comments: 'Comments 2' })}
        serializer = HashSerializer.new(hash, scope: current_user)

        expected = {profile1: { name: 'Name 1', description: 'Description 1 - user' },
                    profile2: { name: 'Name 2', description: 'Description 2 - user' }}

        assert_equal expected, serializer.serializable_hash
      end

      private

      def current_user
        'user'
      end
    end
  end
end
