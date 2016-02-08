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

            has_many :posts do
              link :self do
                href '//example.com/link_author/relationships/posts'
                meta stuff: 'value'
              end
              link :related do
                href '//example.com/link_author/posts'
                meta count: object.posts.count
              end
              include_data false
            end
          end

          def setup
            @post = Post.new(id: 1337, comments: [], author: nil)
            @author = LinkAuthor.new(id: 1337, posts: [@post])
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

          def test_nil_toplevel_links
            hash = ActiveModel::SerializableResource.new(
              @post,
              adapter: :json_api,
              links: nil
            ).serializable_hash
            refute hash.key?(:links), 'No links key to be output'
          end

          def test_nil_toplevel_links_json_adapter
            hash = ActiveModel::SerializableResource.new(
              @post,
              adapter: :json,
              links: nil
            ).serializable_hash
            refute hash.key?(:links), 'No links key to be output'
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

          def test_relationship_links
            hash = serializable(@author, adapter: :json_api).serializable_hash
            expected = {
              links: {
                self: {
                  href: '//example.com/link_author/relationships/posts',
                  meta: { stuff: 'value' }
                },
                related: {
                  href: '//example.com/link_author/posts',
                  meta: { count: 1 }
                }
              }
            }
            assert_equal(expected, hash[:data][:relationships][:posts])
          end
        end
      end
    end
  end
end
