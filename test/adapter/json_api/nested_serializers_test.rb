require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
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
            hash = with_adapter :json_api do
              ActiveModel::SerializableResource.new(@tweet).serializable_hash
            end

            assert_equal(nil, hash)
          end
        end
      end
    end
  end
end
