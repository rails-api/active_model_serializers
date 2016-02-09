require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        class ResourceMetaTest < Minitest::Test
          class MetaHashPostSerializer < ActiveModel::Serializer
            attributes :id
            meta stuff: 'value'
          end

          class MetaBlockPostSerializer < ActiveModel::Serializer
            attributes :id
            meta do
              { comments_count: object.comments.count }
            end
          end

          def setup
            @post = Post.new(id: 1337, comments: [], author: nil)
          end

          def test_meta_hash_object_resource
            hash = ActiveModel::SerializableResource.new(
              @post,
              serializer: MetaHashPostSerializer,
              adapter: :json_api
            ).serializable_hash
            expected = {
              stuff: 'value'
            }
            assert_equal(expected, hash[:data][:meta])
          end

          def test_meta_block_object_resource
            hash = ActiveModel::SerializableResource.new(
              @post,
              serializer: MetaBlockPostSerializer,
              adapter: :json_api
            ).serializable_hash
            expected = {
              comments_count: @post.comments.count
            }
            assert_equal(expected, hash[:data][:meta])
          end

          def test_meta_object_resource_in_array
            hash = ActiveModel::SerializableResource.new(
              [@post, @post],
              each_serializer: MetaBlockPostSerializer,
              adapter: :json_api
            ).serializable_hash
            expected = {
              comments_count: @post.comments.count
            }
            assert_equal([expected, expected], hash[:data].map { |obj| obj[:meta] })
          end
        end
      end
    end
  end
end
