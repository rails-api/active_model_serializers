require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class Json
        class NestedSerializersTest < Minitest::Test
          def setup
            @tweet = Tweet.new(id: 1, body: 'Tweet 1', date: 'Jan 15')
            @share1 = Share.new(id: 1, platform: 'facebook', date: 'Jan 16')
            @author = Author.new(id: 1, name: 'Lucas H.')
            @tweet.author = @author
            @tweet.shares = [@share1]
            @share1.author = @author
            @author.posts = []
            @author.roles = []
            @author.bio = nil
          end

          def test_nested_serializers
            actual = ActiveModel::SerializableResource.new(@tweet, adapter: :json).serializable_hash
            expected = { tweet: { id: 1, body: 'Tweet 1', date: 'Jan 15', author: { id: 1 }, shares: [{ id: 1, platform: 'facebook' }] } }
            assert_equal(expected, actual)
          end
        end
      end
    end
  end
end
