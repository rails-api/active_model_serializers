require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi
      class RelationshipTest < ActiveSupport::TestCase
        setup do
          @blog = Blog.new(id: 1)
          @author = Author.new(id: 1, name: 'Steve K.', blog: @blog)
          @serializer = BlogSerializer.new(@blog)
          ActionController::Base.cache_store.clear
        end

        def test_relationship_with_data
          expected = {
            data: {
              id: '1',
              type: 'blogs'
            }
          }
          test_relationship(expected, options: { include_data: true })
        end

        def test_relationship_with_nil_model
          @serializer = BlogSerializer.new(nil)
          expected = { data: nil }
          test_relationship(expected, options: { include_data: true })
        end

        def test_relationship_with_nil_serializer
          @serializer = nil
          expected = { data: nil }
          test_relationship(expected, options: { include_data: true })
        end

        def test_relationship_with_data_array
          posts = [Post.new(id: 1), Post.new(id: 2)]
          @serializer = ActiveModel::Serializer::CollectionSerializer.new(posts)
          @author.posts = posts
          @author.blog = nil
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
          test_relationship(expected, options: { include_data: true })
        end

        def test_relationship_data_not_included
          test_relationship({}, options: { include_data: false })
        end

        def test_relationship_simple_link
          links = { self: 'a link' }
          test_relationship({ links: { self: 'a link' } }, links: links)
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
          test_relationship(expected, links: links)
        end

        def test_relationship_block_link
          links = { self: proc { object.id.to_s } }
          expected = { links: { self: @blog.id.to_s } }
          test_relationship(expected, links: links)
        end

        def test_relationship_block_link_with_meta
          links = {
            self: proc do
              href object.id.to_s
              meta(id: object.id)
            end
          }
          expected = {
            links: {
              self: {
                href: @blog.id.to_s,
                meta: { id: @blog.id }
              }
            }
          }
          test_relationship(expected, links: links)
        end

        def test_relationship_simple_meta
          meta = { id: '1' }
          expected = { meta: meta }
          test_relationship(expected, meta: meta)
        end

        def test_relationship_block_meta
          meta =  proc do
            { id: object.id }
          end
          expected = {
            meta: {
              id: @blog.id
            }
          }
          test_relationship(expected, meta: meta)
        end

        def test_relationship_with_everything
          links = {
            self: 'a link',
            related: proc do
              href object.id.to_s
              meta object.id
            end

          }
          meta = proc do
            { id: object.id }
          end
          expected = {
            data: {
              id: '1',
              type: 'blogs'
            },
            links: {
              self: 'a link',
              related: {
                href: '1', meta: 1
              }
            },
            meta: {
              id: @blog.id
            }
          }
          test_relationship(expected, meta: meta, options: { include_data: true }, links: links)
        end

        private

        def test_relationship(expected, params = {})
          parent_serializer = AuthorSerializer.new(@author)
          relationship = Relationship.new(parent_serializer, @serializer, nil, params)
          assert_equal(expected, relationship.as_json)
        end
      end
    end
  end
end
