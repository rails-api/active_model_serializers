require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
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
            actual = ActiveModel::SerializableResource.new(@tweet, adapter: :json_api).serializable_hash
            expected = {
              data: {
                id: '1', type: 'tweets', attributes: { body: 'Tweet 1', date: 'Jan 15' },
                relationships: { author: { data: { id: '1', type: 'authors' } },
                                 shares: { data: [{ id: '1', type: 'shares' }] } }
              }
            }
            assert_equal(expected, actual)
          end
        end
      end
    end
  end
end
