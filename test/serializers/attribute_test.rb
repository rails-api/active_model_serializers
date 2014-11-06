require 'test_helper'

module ActiveModel
  class Serializer
    class AttributeTest < Minitest::Test
      def setup
        @blog = Blog.new({ id: 1, name: 'AMS Hints' })
        @blog_serializer = AlternateBlogSerializer.new(@blog)
      end

      def test_attributes_definition
        assert_equal([:id, :title],
                     @blog_serializer.class._attributes)
      end

      def test_json_serializable_hash
        adapter = ActiveModel::Serializer::Adapter::Json.new(@blog_serializer)
        assert_equal({:id=>1, :title=>"AMS Hints"}, adapter.serializable_hash)
      end
    end
  end
end

