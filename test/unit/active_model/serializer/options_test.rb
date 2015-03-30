require 'test_helper'

module ActiveModel
  class Serializer
    class OptionsTest < Minitest::Test
      def setup
        @serializer = ProfileSerializer.new(nil, context: {foo: :bar})
      end

      def test_custom_options_are_accessible_from_serializer
        assert_equal({foo: :bar}, @serializer.context)
      end
    end

    class SerializationOptionsTest < Minitest::Test
      def setup
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @profile_serializer = ProfileSerializer.new(@profile)
        @profile_serializer.instance_eval do
          def description
            serialization_options[:force_the_description]
          end
        end

        @category = Category.new({name: 'Category 1'})
        @category_serializer = CategorySerializer.new(@category)
      end

      def test_filtered_attributes_serialization
        forced_description = "This is a test"
        assert_equal({
          'profile' => { name: 'Name 1', description: forced_description }
        }, @profile_serializer.as_json(force_the_description: forced_description))
      end

      def test_filtered_attributes_serialization_across_association
        assert_equal("'T1'",
            @category_serializer.as_json(highlight_keyword: 'T1')['category'][:posts][0][:title])
      end
    end
  end
end
