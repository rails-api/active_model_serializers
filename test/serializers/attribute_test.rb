require 'test_helper'

module ActiveModel
  class Serializer
    class AttributeTest < Minitest::Test
      def setup
        @blog = Blog.new({ id: 1, name: 'AMS Hints', type: 'stuff' })
        @blog_serializer = AlternateBlogSerializer.new(@blog)
      end

      def test_attributes_definition
        assert_equal([:id, :title],
                     @blog_serializer.class._attributes)
      end

      def test_json_serializable_hash
        adapter = ActiveModel::Serializer::Adapter::Json.new(@blog_serializer)
        assert_equal({blog: { id:1, title:'AMS Hints'}}, adapter.serializable_hash)
      end

      def test_attribute_inheritance_with_key
        inherited_klass = Class.new(AlternateBlogSerializer)
        blog_serializer = inherited_klass.new(@blog)
        adapter = ActiveModel::Serializer::Adapter::FlattenJson.new(blog_serializer)
        assert_equal({:id=>1, :title=>'AMS Hints'}, adapter.serializable_hash)
      end

      def test_multiple_calls_with_the_same_attribute
        serializer_class = Class.new(ActiveModel::Serializer) do
          attribute :title
          attribute :title
        end

        assert_equal([:title], serializer_class._attributes)
      end

      def test_id_attribute_override
        serializer = Class.new(ActiveModel::Serializer) do
          attribute :name, key: :id
        end

        adapter = ActiveModel::Serializer::Adapter::Json.new(serializer.new(@blog))
        assert_equal({ blog: { id: 'AMS Hints' } }, adapter.serializable_hash)
      end

      def test_type_attribute
        attribute_serializer = Class.new(ActiveModel::Serializer) do
          attribute :id, key: :type
        end
        attributes_serializer = Class.new(ActiveModel::Serializer) do
          attributes :type
        end

        adapter = ActiveModel::Serializer::Adapter::Json.new(attribute_serializer.new(@blog))
        assert_equal({ blog: { type: 1} }, adapter.serializable_hash)

        adapter = ActiveModel::Serializer::Adapter::Json.new(attributes_serializer.new(@blog))
        assert_equal({ blog: { type: 'stuff' } }, adapter.serializable_hash)
      end
    end
  end
end
