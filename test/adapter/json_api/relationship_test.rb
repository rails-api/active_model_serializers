require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi
      class RelationshipTest < ActiveSupport::TestCase
        setup do
          ActionController::Base.cache_store.clear
        end

        def test_relationship_with_data
          blog = Blog.new(id: 1)
          author = Author.new(id: 1, name: 'Steve K.', blog: blog)
          serializer = BlogSerializer.new(blog)
          expected = {
            data: {
              id: '1',
              type: 'blogs'
            }
          }
          test_options = { options: { include_data: true }, author: author, serializer: serializer }
          assert_relationship(expected, test_options)
        end

        def test_relationship_with_nil_model
          author = nil
          blog = nil
          serializer = BlogSerializer.new(blog)
          expected = { data: nil }
          test_options = { options: { include_data: true }, author: author, serializer: serializer }
          assert_relationship(expected, test_options)
        end

        def test_relationship_with_nil_serializer
          author = nil
          serializer = nil
          expected = { data: nil }
          test_options = { options: { include_data: true }, author: author, serializer: serializer }
          assert_relationship(expected, test_options)
        end

        def test_relationship_with_data_array
          posts = [Post.new(id: 1), Post.new(id: 2)]
          blog = Blog.new(id: 1)
          author = Author.new(id: 1, name: 'Steve K.', blog: blog)
          serializer = ActiveModel::Serializer::CollectionSerializer.new(posts)
          author.posts = posts
          author.blog = nil
          expected = {
            data: [
              {
                id: '1',
                type: 'posts'
              },
              {
                id: '2',
                type: 'posts'
              }
            ]
          }
          test_options = { options: { include_data: true }, author: author, serializer: serializer }
          assert_relationship(expected, test_options)
        end

        def test_relationship_data_not_included
          expected = { meta: {} }
          test_options = { options: { include_data: false }, author: nil, serializer: nil }
          assert_relationship(expected, test_options)
        end

        def test_relationship_many_links
          links = {
            self: 'a link',
            related: 'another link'
          }
          expected = {
            links: {
              self: 'a link',
              related: 'another link'
            }
          }
          test_options = { links: links, author: nil, serializer: nil }
          assert_relationship(expected, test_options)
        end

        def test_relationship_block_link_with_meta
          links = {
            self: proc do
              href object.id.to_s
              meta(id: object.id)
            end
          }
          blog = Blog.new(id: 1)
          author = Author.new(id: 1, name: 'Steve K.', blog: blog)
          expected = {
            links: {
              self: {
                href: blog.id.to_s,
                meta: { id: blog.id }
              }
            }
          }
          serializer = BlogSerializer.new(blog)
          test_options = { links: links, author: author, serializer: serializer }
          assert_relationship(expected, test_options)
        end

        def test_relationship_simple_meta
          meta = { id: '1' }
          expected = { meta: meta }
          test_options = { meta: meta, author: nil, serializer: nil }
          assert_relationship(expected, test_options)
        end

        def test_relationship_block_meta
          meta =  proc do
            { id: object.id }
          end
          blog = Blog.new(id: 1)
          author = Author.new(id: 1, name: 'Steve K.', blog: blog)
          serializer = BlogSerializer.new(blog)
          expected = {
            meta: {
              id: blog.id
            }
          }
          test_options = { meta: meta, author: author, serializer: serializer }
          assert_relationship(expected, test_options)
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

          model_attributes = { bio: Bio.new(id: 1337) }
          relationship_name = :bio
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_one :bio do
              link :self, '//example.com/link_author/relationships/bio'
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_block_link
          expected = {
            data: { id: '1337', type: 'profiles' },
            links: { related: '//example.com/profiles/1337' }
          }

          model_attributes = { profile: Profile.new(id: 1337) }
          relationship_name = :profile
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_one :profile do
              id = object.profile.id
              link :related do
                "//example.com/profiles/#{id}" if id != 123
              end
            end
          end
          assert_equal(expected, actual)
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

          model_attributes = { likes: [Like.new(id: 1337)] }
          relationship_name = :likes
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_many :likes do
              link :related do
                ids = object.likes.map(&:id).join(',')
                href "//example.com/likes/#{ids}"
                meta ids: ids
              end
              meta liked: object.likes.any?
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_nil_link
          expected = {
            data: { id: '123', type: 'profiles' }
          }

          model_attributes = { profile: Profile.new(id: 123) }
          relationship_name = :profile
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_one :profile do
              id = object.profile.id
              link :related do
                "//example.com/profiles/#{id}" if id != 123
              end
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_block_link_href
          expected = {
            data: [{ id: '1337', type: 'locations' }],
            links: {
              related: { href: '//example.com/locations/1337' }
            }
          }

          model_attributes = { locations: [Location.new(id: 1337)] }
          relationship_name = :locations
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_many :locations do
              link :related do
                ids = object.locations.map(&:id).join(',')
                href "//example.com/locations/#{ids}"
              end
            end
          end
          assert_equal(expected, actual)
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

          model_attributes =  { posts: [Post.new(id: 1337, comments: [], author: nil)] }
          relationship_name = :posts
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_many :posts do
              link :related do
                ids = object.posts.map(&:id).join(',')
                href "//example.com/posts/#{ids}"
                meta ids: ids
              end
            end
          end
          assert_equal(expected, actual)
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

          model_attributes = { comments: [Comment.new(id: 1337)] }
          relationship_name = :comments
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_many :comments do
              link :self do
                meta ids: [1]
              end
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_meta
          expected = {
            data: [{ id: 'from-serializer-method', type: 'roles' }],
            meta: { count: 1 }
          }

          model_attributes = { roles: [Role.new(id: 'from-record')] }
          relationship_name = :roles
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            has_many :roles do |serializer|
              meta count: object.roles.count
              serializer.cached_roles
            end
            def cached_roles
              [
                Role.new(id: 'from-serializer-method')
              ]
            end
          end
          assert_equal(expected, actual)
        end

        def test_relationship_not_including_data
          expected = {
            links: { self: '//example.com/link_author/relationships/blog' }
          }

          model_attributes = { blog: Object }
          relationship_name = :blog
          model = new_model(model_attributes)
          model.define_singleton_method(:read_attribute_for_serialization) do |attr|
            fail 'should not be called' if attr == :blog
            super(attr)
          end
          assert_nothing_raised do
            actual = build_serializer_and_serialize_relationship(model, relationship_name) do
              has_one :blog do
                link :self, '//example.com/link_author/relationships/blog'
                include_data false
              end
            end
            assert_equal(expected, actual)
          end
        end

        def test_relationship_including_data_explicit
          expected = {
            data: { id: '1337', type: 'authors' },
            meta: { name: 'Dan Brown' }
          }

          model_attributes = { reviewer: Author.new(id: 1337) }
          relationship_name = :reviewer
          model = new_model(model_attributes)
          actual = build_serializer_and_serialize_relationship(model, relationship_name) do
            belongs_to :reviewer do
              meta name: 'Dan Brown'
              include_data true
            end
          end
          assert_equal(expected, actual)
        end

        private

        def assert_relationship(expected, test_options = {})
          options = test_options.delete(:options) || {}
          options[:links] = test_options.delete(:links)
          options[:meta] = test_options.delete(:meta)
          author = test_options.delete(:author)
          association_serializer = test_options.delete(:serializer)

          if association_serializer && association_serializer.object
            association_name = association_serializer.json_key.to_sym
            options[:serializer] = association_serializer
            association = ::ActiveModel::Serializer::Association.new(association_name, options, nil)
          else
            options[:serializer] = association
            association = ::ActiveModel::Serializer::Association.new(:association_name_not_used, options, nil)
          end

          serializable_resource_options = {} # adapter.instance_options
          parent_serializer = AuthorSerializer.new(author)
          relationship = Relationship.new(parent_serializer, serializable_resource_options, association)
          assert_equal(expected, relationship.as_json)
        end

        def build_serializer_and_serialize_relationship(model, relationship_name, &block)
          serializer_class = Class.new(ActiveModel::Serializer, &block)
          hash = serializable(model, serializer: serializer_class, adapter: :json_api).serializable_hash
          hash[:data][:relationships][relationship_name]
        end

        def new_model(model_attributes)
          Class.new(ActiveModelSerializers::Model) do
            attr_accessor(*model_attributes.keys)

            def self.name
              'TestModel'
            end
          end.new(model_attributes)
        end
      end
    end
  end
end
