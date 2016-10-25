require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class ResourceMetaTest < ActiveSupport::TestCase
          class MetaHashPostSerializer < ActiveModel::Serializer
            attributes :id
            meta cache: { expires: 3600 }
          end

          class MetaBlockPostSerializer < ActiveModel::Serializer
            attributes :id
            meta do
              { comments_count: object.comments.count }
            end
          end

          class MetaBlockParamPostSerializer < ActiveModel::Serializer
            attributes :id
            meta do |serializer|
              {
                actions: serializer.actions
              }
            end

            def actions
              instance_options[:actions] || []
            end
          end

          class MetaBlockPostBlankMetaSerializer < ActiveModel::Serializer
            attributes :id
            meta do
              {}
            end
          end

          class MetaBlockPostEmptyStringSerializer < ActiveModel::Serializer
            attributes :id
            meta do
              ''
            end
          end

          setup do
            @post = Post.new(id: 1337, comments: [], author: nil)
          end

          test 'resource meta as hash' do
            hash = ActiveModelSerializers::SerializableResource.new(
              @post,
              serializer: MetaHashPostSerializer,
              adapter: :json_api
            ).serializable_hash
            expected = {
              cache: { expires: 3600 }
            }
            assert_equal(expected, hash[:data][:meta])
          end

          test 'resource meta as block' do
            hash = ActiveModelSerializers::SerializableResource.new(
              @post,
              serializer: MetaBlockPostSerializer,
              adapter: :json_api
            ).serializable_hash
            expected = {
              :"comments-count" => @post.comments.count
            }
            assert_equal(expected, hash[:data][:meta])
          end

          test 'resource meta within collections' do
            post2 = Post.new(id: 1339, comments: [Comment.new])
            posts = [@post, post2]
            hash = ActiveModelSerializers::SerializableResource.new(
              posts,
              each_serializer: MetaBlockPostSerializer,
              adapter: :json_api
            ).serializable_hash
            expected = {
              data: [
                { id: '1337', type: 'posts', meta: { :"comments-count" => 0 } },
                { id: '1339', type: 'posts', meta: { :"comments-count" => 1 } }
              ]
            }
            assert_equal(expected, hash)
          end

          test 'empty resource meta hash' do
            hash = ActiveModelSerializers::SerializableResource.new(
              @post,
              serializer: MetaBlockPostBlankMetaSerializer,
              adapter: :json_api
            ).serializable_hash
            refute hash[:data].key? :meta
          end

          test 'empty resource meta string' do
            hash = ActiveModelSerializers::SerializableResource.new(
              @post,
              serializer: MetaBlockPostEmptyStringSerializer,
              adapter: :json_api
            ).serializable_hash
            refute hash[:data].key? :meta
          end

          test 'resource meta as block with parameter' do
            hash = ActiveModelSerializers::SerializableResource.new(
              @post,
              serializer: MetaBlockParamPostSerializer,
              adapter: :json_api,
              actions: {
                update: {
                  method: 'PUT'
                },
                delete: {
                  method: 'DELETE'
                }
              }
            ).serializable_hash
            expected = {
              data: {
                id: '1337',
                type: 'posts',
                meta: {
                  actions: {
                    update: {
                      method: 'PUT'
                    },
                    delete: {
                      method: 'DELETE'
                    }
                  }
                }
              }
            }
            assert_equal(expected, hash)
          end
        end
      end
    end
  end
end
