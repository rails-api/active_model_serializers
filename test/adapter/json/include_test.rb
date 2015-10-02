require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class Json
        class IncludeTest < Minitest::Test
          def setup
            @author = Author.new(id: 1, name: 'Steve K.')

            @post = Post.new(id: 42, title: 'New Post', body: 'Body')
            @post.author = @author
            @author.posts = [@post]
            @author.roles = []
            @author.bio = {}
          end

          def test_no_associations
            resource = SerializableResource.new(
              @author,
              adapter: :json,
              include: [])

            expected = {
              author: {
                id: 1,
                name: 'Steve K.'
              }
            }

            assert_equal(expected, resource.serializable_hash)
          end
        end
      end
    end
  end
end
