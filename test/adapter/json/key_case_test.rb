require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class Json
      class KeyCaseTest < ActiveSupport::TestCase
        def mock_request(key_transform = nil)
          context = Minitest::Mock.new
          context.expect(:request_url, URI)
          context.expect(:query_parameters, {})
          context.expect(:key_transform, key_transform)
          @options = {}
          @options[:serialization_context] = context
        end

        Post = Class.new(::Model)
        class PostSerializer < ActiveModel::Serializer
          attributes :id, :title, :body, :publish_at
        end

        def setup
          ActionController::Base.cache_store.clear
          @blog = Blog.new(id: 1, name: 'My Blog!!', special_attribute: 'neat')
          serializer = CustomBlogSerializer.new(@blog)
          @adapter = ActiveModelSerializers::Adapter::Json.new(serializer)
        end

        def test_key_transform_default
          mock_request
          assert_equal({
            blog: { id: 1, special_attribute: 'neat', articles: nil }
          }, @adapter.serializable_hash(@options))
        end

        def test_key_transform_global_config
          mock_request
          result = with_config(key_transform: :camel_lower) do
            @adapter.serializable_hash(@options)
          end
          assert_equal({
            blog: { id: 1, specialAttribute: 'neat', articles: nil }
          }, result)
        end

        def test_key_transform_serialization_ctx_overrides_global_config
          mock_request(:camel)
          result = with_config(key_transform: :camel_lower) do
            @adapter.serializable_hash(@options)
          end
          assert_equal({
            Blog: { Id: 1, SpecialAttribute: 'neat', Articles: nil }
          }, result)
        end

        def test_key_transform_undefined
          mock_request(:blam)
          result = nil
          assert_raises NoMethodError do
            result = @adapter.serializable_hash(@options)
          end
        end

        def test_key_transform_dashed
          mock_request(:dashed)
          assert_equal({
            blog: { id: 1, :"special-attribute" => 'neat', articles: nil }
          }, @adapter.serializable_hash(@options))
        end

        def test_key_transform_unaltered
          mock_request(:unaltered)
          assert_equal({
            blog: { id: 1, special_attribute: 'neat', articles: nil }
          }, @adapter.serializable_hash(@options))
        end

        def test_key_transform_camel
          mock_request(:camel)
          assert_equal({
            Blog: { Id: 1, SpecialAttribute: 'neat', Articles: nil }
          }, @adapter.serializable_hash(@options))
        end

        def test_key_transform_camel_lower
          mock_request(:camel_lower)
          assert_equal({
            blog: { id: 1, specialAttribute: 'neat', articles: nil }
          }, @adapter.serializable_hash(@options))
        end
      end
    end
  end
end
