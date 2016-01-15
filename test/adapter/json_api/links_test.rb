require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class LinksTest < ActiveSupport::TestCase
          LinkAuthor = Class.new(::Model)
          class LinkAuthorSerializer < ActiveModel::Serializer
            link :self do
              href "//example.com/link_author/#{object.id}"
              meta stuff: 'value'
            end

            link :other, '//example.com/resource'

            link :yet_another do
              "//example.com/resource/#{object.id}"
            end
          end

          def setup
            @post = Post.new(id: 1337, comments: [], author: nil)
            @author = LinkAuthor.new(id: 1337)
          end

          def test_toplevel_links
            hash = ActiveModel::SerializableResource.new(
              @post,
              adapter: :json_api,
              links: {
                self: {
                  href: '//example.com/posts',
                  meta: {
                    stuff: 'value'
                  }
                }
              }).serializable_hash
            expected = {
              self: {
                href: '//example.com/posts',
                meta: {
                  stuff: 'value'
                }
              }
            }
            assert_equal(expected, hash[:links])
          end

          def test_resource_links
            hash = serializable(@author, adapter: :json_api).serializable_hash
            expected = {
              self: {
                href: '//example.com/link_author/1337',
                meta: {
                  stuff: 'value'
                }
              },
              other: '//example.com/resource',
              yet_another: '//example.com/resource/1337'
            }
            assert_equal(expected, hash[:data][:links])
          end
        end
      end
    end
  end
end
