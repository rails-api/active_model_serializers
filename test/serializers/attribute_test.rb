require 'test_helper'

module ActiveModel
  class Serializer
    class AttributeTest < ActiveSupport::TestCase
      def setup
        @blog = Blog.new(id: 1, name: 'AMS Hints', type: 'stuff')
        @blog_serializer = AlternateBlogSerializer.new(@blog)
      end

      def test_attributes_definition
        assert_equal([:id, :title],
          @blog_serializer.class._attributes)
      end

      def test_json_serializable_hash
        adapter = ActiveModel::Serializer::Adapter::Json.new(@blog_serializer)
        assert_equal({ blog: { id: 1, title: 'AMS Hints' } }, adapter.serializable_hash)
      end

      def test_attribute_inheritance_with_key
        inherited_klass = Class.new(AlternateBlogSerializer)
        blog_serializer = inherited_klass.new(@blog)
        adapter = ActiveModel::Serializer::Adapter::Attributes.new(blog_serializer)
        assert_equal({ :id => 1, :title => 'AMS Hints' }, adapter.serializable_hash)
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

      def test_object_attribute_override
        serializer = Class.new(ActiveModel::Serializer) do
          attribute :name, key: :object
        end

        adapter = ActiveModel::Serializer::Adapter::Json.new(serializer.new(@blog))
        assert_equal({ blog: { object: 'AMS Hints' } }, adapter.serializable_hash)
      end

      def test_type_attribute
        attribute_serializer = Class.new(ActiveModel::Serializer) do
          attribute :id, key: :type
        end
        attributes_serializer = Class.new(ActiveModel::Serializer) do
          attributes :type
        end

        adapter = ActiveModel::Serializer::Adapter::Json.new(attribute_serializer.new(@blog))
        assert_equal({ blog: { type: 1 } }, adapter.serializable_hash)

        adapter = ActiveModel::Serializer::Adapter::Json.new(attributes_serializer.new(@blog))
        assert_equal({ blog: { type: 'stuff' } }, adapter.serializable_hash)
      end

      def test_id_attribute_override_before
        serializer = Class.new(ActiveModel::Serializer) do
          def id
            'custom'
          end

          attribute :id
        end

        hash = ActiveModel::SerializableResource.new(@blog, adapter: :json, serializer: serializer).serializable_hash

        assert_equal('custom', hash[:blog][:id])
      end

      PostWithVirtualAttribute = Class.new(::Model)
      class PostWithVirtualAttributeSerializer < ActiveModel::Serializer
        attribute :name do
          "#{object.first_name} #{object.last_name}"
        end
      end

      def test_virtual_attribute_block
        post = PostWithVirtualAttribute.new(first_name: 'Lucas', last_name: 'Hosseini')
        hash = serializable(post).serializable_hash
        expected = { name: 'Lucas Hosseini' }

        assert_equal(expected, hash)
      end

      def test_conditional_attributes
        serializer = Class.new(ActiveModel::Serializer) do
          attribute :if_attribute_included, if: :true
          attribute :if_attribute_excluded, if: :false
          attribute :unless_attribute_included, unless: :false
          attribute :unless_attribute_excluded, unless: :true

          def true
            true
          end

          def false
            false
          end
        end

        model = ::Model.new
        hash = serializable(model, serializer: serializer).serializable_hash
        expected = { if_attribute_included: nil, unless_attribute_included: nil }

        assert_equal(expected, hash)
      end
    end
  end
end
