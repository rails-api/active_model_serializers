require 'test_helper'

module ActiveModel
  class Serializer
    class AttributesTest < ActiveSupport::TestCase
      def setup
        @profile = Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
        @profile_serializer = ProfileSerializer.new(@profile)
        @comment = Comment.new(id: 1, body: 'ZOMG!!', date: '2015')
        @serializer_klass = Class.new(CommentSerializer)
        @serializer_klass_with_new_attributes = Class.new(CommentSerializer) do
          attributes :date, :likes
        end
      end

      test 'attributes_definition' do
        assert_equal([:name, :description],
          @profile_serializer.class._attributes)
      end

      test 'attributes_inheritance_definition' do
        assert_equal([:id, :body], @serializer_klass._attributes)
      end

      test 'attributes_inheritance' do
        serializer = @serializer_klass.new(@comment)
        assert_equal({ id: 1, body: 'ZOMG!!' },
          serializer.attributes)
      end

      test 'attribute_inheritance_with_new_attribute_definition' do
        assert_equal([:id, :body, :date, :likes], @serializer_klass_with_new_attributes._attributes)
        assert_equal([:id, :body], CommentSerializer._attributes)
      end

      test 'attribute_inheritance_with_new_attribute' do
        serializer = @serializer_klass_with_new_attributes.new(@comment)
        assert_equal({ id: 1, body: 'ZOMG!!', date: '2015', likes: nil },
          serializer.attributes)
      end

      test 'multiple_calls_with_the_same_attribute' do
        serializer_class = Class.new(ActiveModel::Serializer) do
          attributes :id, :title
          attributes :id, :title, :title, :body
        end

        assert_equal([:id, :title, :body], serializer_class._attributes)
      end
    end
  end
end
