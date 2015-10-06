require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class LinksTest < Minitest::Test
          def setup
            @post = Post.new(id: 1337, comments: [], author: nil)
          end

          def test_toplevel_links
            hash = ActiveModel::SerializableResource.new(
              @post,
              adapter: :json_api,
              links: {
                self: {
                  href: '//posts'
                }
              }).serializable_hash
            expected = {
              self: {
                href: '//posts'
              }
            }
            assert_equal(expected, hash[:links])
          end
        end
      end
    end
  end
end
