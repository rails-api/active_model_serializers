require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class Json
      class KeyCaseTest < ActiveSupport::TestCase
        def mock_request(key_transform = nil)
          context = Minitest::Mock.new
          context.expect(:request_url, URI)
          context.expect(:query_parameters, {})
          options = {}
          options[:key_transform] = key_transform if key_transform
          options[:serialization_context] = context
          serializer = CustomBlogSerializer.new(@blog)
          @adapter = ActiveModelSerializers::Adapter::Json.new(serializer, options)
        end

        class Post < ::Model; end
        class PostSerializer < ActiveModel::Serializer
          attributes :id, :title, :body, :publish_at
        end

        setup do
          ActionController::Base.cache_store.clear
          @blog = Blog.new(id: 1, name: 'My Blog!!', special_attribute: 'neat')
        end

        test 'transform_default' do
          mock_request
          assert_equal({
                         blog: { id: 1, special_attribute: 'neat', articles: nil }
                       }, @adapter.serializable_hash)
        end

        test 'transform_global_config' do
          mock_request
          result = with_config(key_transform: :camel_lower) do
            @adapter.serializable_hash
          end
          assert_equal({
                         blog: { id: 1, specialAttribute: 'neat', articles: nil }
                       }, result)
        end

        test 'transform_serialization_ctx_overrides_global_config' do
          mock_request(:camel)
          result = with_config(key_transform: :camel_lower) do
            @adapter.serializable_hash
          end
          assert_equal({
                         Blog: { Id: 1, SpecialAttribute: 'neat', Articles: nil }
                       }, result)
        end

        test 'transform_undefined' do
          mock_request(:blam)
          result = nil
          assert_raises NoMethodError do
            result = @adapter.serializable_hash
          end
        end

        test 'transform_dash' do
          mock_request(:dash)
          assert_equal({
                         blog: { id: 1, :"special-attribute" => 'neat', articles: nil }
                       }, @adapter.serializable_hash)
        end

        test 'transform_unaltered' do
          mock_request(:unaltered)
          assert_equal({
                         blog: { id: 1, special_attribute: 'neat', articles: nil }
                       }, @adapter.serializable_hash)
        end

        test 'transform_camel' do
          mock_request(:camel)
          assert_equal({
                         Blog: { Id: 1, SpecialAttribute: 'neat', Articles: nil }
                       }, @adapter.serializable_hash)
        end

        test 'transform_camel_lower' do
          mock_request(:camel_lower)
          assert_equal({
                         blog: { id: 1, specialAttribute: 'neat', articles: nil }
                       }, @adapter.serializable_hash)
        end
      end
    end
  end
end
