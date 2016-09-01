require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class RelationshipTest < ActiveSupport::TestCase
          class RelationshipAuthor < ::Model; end

          class RelationshipAuthorSerializer < ActiveModel::Serializer
            has_one :bio do
              link :self, '//example.com/link_author/relationships/bio'
            end

            has_one :profile do
              id = object.profile.id
              link :related do
                "//example.com/profiles/#{id}" if id != 123
              end
            end

            has_many :locations do
              link :related do
                ids = object.locations.map(&:id).join(',')
                href "//example.com/locations/#{ids}"
              end
            end

            has_many :posts do
              link :related do
                ids = object.posts.map(&:id).join(',')
                href "//example.com/posts/#{ids}"
                meta ids: ids
              end
            end

            has_many :comments do
              link :self do
                meta ids: [1]
              end
            end

            has_many :roles do |serializer|
              meta count: object.posts.count
              serializer.cached_roles
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
                ids = object.likes.map(&:id).join(',')
                href "//example.com/likes/#{ids}"
                meta ids: ids
              end
              meta liked: object.likes.any?
            end

            def cached_roles
              [
                Role.new(id: 'from-serializer-method')
              ]
            end
          end

          def setup
            @post = Post.new(id: 1337, comments: [], author: nil)
            @bio = Bio.new(id: 1337)
            @like = Like.new(id: 1337)
            @role = Role.new(id: 'from-record')
            @profile = Profile.new(id: 1337)
            @location = Location.new(id: 1337)
            @reviewer = Author.new(id: 1337)
            @comment = Comment.new(id: 1337)
            @author = RelationshipAuthor.new(
              id: 1337,
              posts: [@post],
              reviewer: @reviewer,
              bio: @bio,
              likes: [@like],
              roles: [@role],
              locations: [@location],
              profile: @profile,
              comments: [@comment]
            )
          end

          def test_relationship_simple_link
            expected = {
              data: {
                id: '1337',
                type: 'bios'
              },
              links: {
                self: '//example.com/link_author/relationships/bio'
              }
            }

            author = @author.dup
            assert_author_relationship_serialized(expected, author, :bio)
          end

          def test_relationship_block_link
            expected = {
              data: { id: '1337', type: 'profiles' },
              links: { related: '//example.com/profiles/1337' }
            }

            author = @author.dup
            assert_author_relationship_serialized(expected, author, :profile)
          end

          def test_relationship_nil_link
            expected = {
              data: { id: '123', type: 'profiles' }
            }

            author = @author.dup
            author.profile.id = 123
            assert_author_relationship_serialized(expected, author, :profile)
          end

          def test_relationship_block_link_href
            expected = {
              data: [{ id: '1337', type: 'locations' }],
              links: {
                related: { href: '//example.com/locations/1337' }
              }
            }

            author = @author.dup
            assert_author_relationship_serialized(expected, author, :locations)
          end

          def test_relationship_block_link_href_and_meta
            expected = {
              data: [{ id: '1337', type: 'posts' }],
              links: {
                related: {
                  href: '//example.com/posts/1337',
                  meta: { ids: '1337' }
                }
              }
            }

            author = @author.dup
            assert_author_relationship_serialized(expected, author, :posts)
          end

          def test_relationship_block_link_meta
            expected = {
              data: [{ id: '1337', type: 'comments' }],
              links: {
                self: {
                  meta: { ids: [1] }
                }
              }
            }

            author = @author.dup
            assert_author_relationship_serialized(expected, author, :comments)
          end

          def test_relationship_meta
            expected = {
              data: [{ id: 'from-serializer-method', type: 'roles' }],
              meta: { count: 1 }
            }

            author = @author.dup
            assert_author_relationship_serialized(expected, author, :roles)
          end

          def test_relationship_not_including_data
            expected = {
              links: { self: '//example.com/link_author/relationships/blog' }
            }

            author = @author.dup
            author.define_singleton_method(:read_attribute_for_serialization) do |attr|
              fail 'should not be called' if attr == :blog
              super(attr)
            end
            assert_nothing_raised do
              assert_author_relationship_serialized(expected, author, :blog)
            end
          end

          def test_relationship_including_data_explicit
            expected = {
              data: { id: '1337', type: 'authors' },
              meta: { name: 'Dan Brown' }
            }

            author = @author.dup
            assert_author_relationship_serialized(expected, author, :reviewer)
          end

          def test_relationship_with_everything
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

            author = @author.dup
            assert_author_relationship_serialized(expected, author, :likes)
          end

          private

          def assert_author_relationship_serialized(expected, author, relationship_name)
            hash = serializable(author, adapter: :json_api).serializable_hash
            actual_relationship = hash[:data][:relationships][relationship_name]
            assert_equal(expected, actual_relationship)
          end
        end
      end
    end
  end
end
