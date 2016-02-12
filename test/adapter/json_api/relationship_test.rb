require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class RelationshipTest < ActiveSupport::TestCase
          RelationshipAuthor = Class.new(::Model)
          class RelationshipAuthorSerializer < ActiveModel::Serializer
            has_one :bio do
              link :self, '//example.com/link_author/relationships/bio'
            end

            has_one :profile do
              link :related do
                "//example.com/profiles/#{object.profile.id}"
              end
            end

            has_many :locations do
              link :related do
                ids = object.locations.map!(&:id).join(',')
                href "//example.com/locations/#{ids}"
              end
            end

            has_many :posts do
              link :related do
                ids = object.posts.map!(&:id).join(',')
                href "//example.com/posts/#{ids}"
                meta ids: ids
              end
            end

            has_many :roles do
              meta count: object.posts.count
            end

            has_one :blog do
              link :self, '//example.com/link_author/relationships/blog'
              include_data false
            end

            belongs_to :reviewer do
              meta name: 'Dan Brown'
              include_data true
            end

            has_many :likes do
              link :related do
                ids = object.likes.map!(&:id).join(',')
                href "//example.com/likes/#{ids}"
                meta ids: ids
              end
              meta liked: object.likes.any?
            end
          end

          def setup
            @post = Post.new(id: 1337, comments: [], author: nil)
            @blog = Blog.new(id: 1337, name: 'extra')
            @bio = Bio.new(id: 1337)
            @like = Like.new(id: 1337)
            @role = Role.new(id: 1337)
            @profile = Profile.new(id: 1337)
            @location = Location.new(id: 1337)
            @reviewer = Author.new(id: 1337)
            @author = RelationshipAuthor.new(
              id: 1337,
              posts: [@post],
              blog: @blog,
              reviewer: @reviewer,
              bio: @bio,
              likes: [@like],
              roles: [@role],
              locations: [@location],
              profile: @profile
            )
          end

          def test_relationship_simple_link
            hash = serializable(@author, adapter: :json_api).serializable_hash
            expected = {
              data: {
                id: '1337',
                type: 'bios'
              },
              links: {
                self: '//example.com/link_author/relationships/bio'
              }
            }
            assert_equal(expected, hash[:data][:relationships][:bio])
          end

          def test_relationship_block_link
            hash = serializable(@author, adapter: :json_api).serializable_hash
            expected = {
              data: { id: '1337', type: 'profiles' },
              links: { related: '//example.com/profiles/1337' }
            }
            assert_equal(expected, hash[:data][:relationships][:profile])
          end

          def test_relationship_block_link_href
            hash = serializable(@author, adapter: :json_api).serializable_hash
            expected = {
              data: [{ id: '1337', type: 'locations' }],
              links: {
                related: { href: '//example.com/locations/1337' }
              }
            }
            assert_equal(expected, hash[:data][:relationships][:locations])
          end

          def test_relationship_block_link_meta
            hash = serializable(@author, adapter: :json_api).serializable_hash
            expected = {
              data: [{ id: '1337', type: 'posts' }],
              links: {
                related: {
                  href: '//example.com/posts/1337',
                  meta: { ids: '1337' }
                }
              }
            }
            assert_equal(expected, hash[:data][:relationships][:posts])
          end

          def test_relationship_meta
            hash = serializable(@author, adapter: :json_api).serializable_hash
            expected = {
              data: [{ id: '1337', type: 'roles' }],
              meta: { count: 1 }
            }
            assert_equal(expected, hash[:data][:relationships][:roles])
          end

          def test_relationship_not_including_data
            hash = serializable(@author, adapter: :json_api).serializable_hash
            expected = {
              links: { self: '//example.com/link_author/relationships/blog' }
            }
            assert_equal(expected, hash[:data][:relationships][:blog])
          end

          def test_relationship_including_data_explicit
            hash = serializable(@author, adapter: :json_api).serializable_hash
            expected = {
              data: { id: '1337', type: 'authors' },
              meta: { name: 'Dan Brown' }
            }
            assert_equal(expected, hash[:data][:relationships][:reviewer])
          end

          def test_relationship_with_everything
            hash = serializable(@author, adapter: :json_api).serializable_hash
            expected = {
              data: [{ id: '1337', type: 'likes' }],
              links: {
                related: {
                  href: '//example.com/likes/1337',
                  meta: { ids: '1337' }
                }
              },
              meta: { liked: true }
            }
            assert_equal(expected, hash[:data][:relationships][:likes])
          end
        end
      end
    end
  end
end
