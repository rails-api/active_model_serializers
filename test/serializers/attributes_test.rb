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

      def test_attributes_definition
        assert_equal([:name, :description],
          @profile_serializer.class._attributes)
      end

      def test_attributes_inheritance_definition
        assert_equal([:id, :body], @serializer_klass._attributes)
      end

      def test_attributes_inheritance
        serializer = @serializer_klass.new(@comment)
        assert_equal({ id: 1, body: 'ZOMG!!' },
          serializer.attributes)
      end

      def test_attribute_inheritance_with_new_attribute_definition
        assert_equal([:id, :body, :date, :likes], @serializer_klass_with_new_attributes._attributes)
        assert_equal([:id, :body], CommentSerializer._attributes)
      end

      def test_attribute_inheritance_with_new_attribute
        serializer = @serializer_klass_with_new_attributes.new(@comment)
        assert_equal({ id: 1, body: 'ZOMG!!', date: '2015', likes: nil },
          serializer.attributes)
      end

      def test_multiple_calls_with_the_same_attribute
        serializer_class = Class.new(ActiveModel::Serializer) do
          attributes :id, :title
          attributes :id, :title, :title, :body
        end

        assert_equal([:id, :title, :body], serializer_class._attributes)
      end

      # rubocop:disable Metrics/AbcSize
      def test_multiple_conditional_attributes
        model = ::Model.new(true: true, false: false)

        scenarios = [
          { options: { if:     :true  }, included: true  },
          { options: { if:     :false }, included: false },
          { options: { unless: :false }, included: true  },
          { options: { unless: :true  }, included: false },
          { options: { if:     'object.true'  }, included: true  },
          { options: { if:     'object.false' }, included: false },
          { options: { unless: 'object.false' }, included: true  },
          { options: { unless: 'object.true'  }, included: false },
          { options: { if:     -> { object.true }  }, included: true  },
          { options: { if:     -> { object.false } }, included: false },
          { options: { unless: -> { object.false } }, included: true  },
          { options: { unless: -> { object.true }  }, included: false },
          { options: { if:     -> (s) { s.object.true }  }, included: true  },
          { options: { if:     -> (s) { s.object.false } }, included: false },
          { options: { unless: -> (s) { s.object.false } }, included: true  },
          { options: { unless: -> (s) { s.object.true }  }, included: false }
        ]

        scenarios.each do |s|
          serializer = Class.new(ActiveModel::Serializer) do
            attributes :attribute1, :attribute2, s[:options]

            def true
              true
            end

            def false
              false
            end
          end

          hash = serializable(model, serializer: serializer).serializable_hash
          assert_equal(s[:included], hash.key?(:attribute1), "Error with #{s[:options]}")
          assert_equal(s[:included], hash.key?(:attribute2), "Error with #{s[:options]}")
        end
      end
    end
  end
end
