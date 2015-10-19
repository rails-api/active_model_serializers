require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class Json
        class ArrayTest < Minitest::Test
          def setup
            @comment = Comment.new
            @post = Post.new
            @resource = build_named_collection @comment, @post
          end

          def build_named_collection(*resource)
            resource.define_singleton_method(:name) { 'MeResource' }
            resource
          end

          def test_root_default
            serializer = ArraySerializer.new([@comment, @post])
            adapter = Json.new(serializer)
            assert_equal(:comments, adapter.send(:root))
          end

          def test_root
            serializer = ArraySerializer.new([@comment, @post])
            adapter = Json.new(serializer, root: 'custom_root')
            assert_equal(:custom_root, adapter.send(:root))
          end

          def test_root_with_no_serializers
            serializer = ArraySerializer.new([])
            adapter = Json.new(serializer, root: 'custom_root')
            assert_equal(:custom_root, adapter.send(:root))
          end

          def test_root_with_resource_with_name_and_serializers
            serializer = ArraySerializer.new(@resource)
            adapter = Json.new(serializer)
            assert_equal(:comments, adapter.send(:root))
          end

          def test_root_with_resource_with_name_and_no_serializers
            serializer = ArraySerializer.new(build_named_collection)
            adapter = Json.new(serializer)
            assert_equal(:me_resources, adapter.send(:root))
          end

          def test_root_with_resource_with_nil_name_and_no_serializers
            resource = []
            resource.define_singleton_method(:name) { nil }
            serializer = ArraySerializer.new(resource)
            adapter = Json.new(serializer)
            assert_equal(:'', adapter.send(:root))
          end

          def test_root_with_resource_without_name_and_no_serializers
            serializer = ArraySerializer.new([])
            adapter = Json.new(serializer)
            assert_equal(:'', adapter.send(:root))
          end

          def test_root_with_explicit_root
            serializer = ArraySerializer.new(@resource)
            adapter = Json.new(serializer, root: 'custom_root')
            assert_equal(:custom_root, adapter.send(:root))
          end

          def test_root_with_explicit_root_and_no_serializers
            serializer = ArraySerializer.new(build_named_collection)
            adapter = Json.new(serializer, root: 'custom_root')
            assert_equal(:custom_root, adapter.send(:root))
          end
        end
      end
    end
  end
end
