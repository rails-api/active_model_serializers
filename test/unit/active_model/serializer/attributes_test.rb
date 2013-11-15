require 'test_helper'

module ActiveModel
  class Serializer
    class AttributesTest < ActiveModel::TestCase
      def setup
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @profile_serializer = ProfileSerializer.new(@profile)
      end

      def test_attributes_definition
        assert_equal([:name, :description],
                     @profile_serializer.class._attributes)
      end

      def test_attributes_serialization_using_serializable_hash
        assert_equal({
          name: 'Name 1', description: 'Description 1'
        }, @profile_serializer.serializable_hash)
      end

      def test_attributes_serialization_using_as_json
        assert_equal({
          'profile' => { name: 'Name 1', description: 'Description 1' }
        }, @profile_serializer.as_json)
      end
    end

    class HashKeyTest < ActiveModel::TestCase
      def setup
        @post = Post.new({ title: 'test', body: 'lorem ipsum', created_at: Time.now, updated_at: Time.now })
        @post_serializer = PostSerializer.new(@post)
      end

      def test_attributes_serialization_using_camelcase_key_conversion
        @post_serializer.convert_type = 'camelcase'
        assert_match({
          title: 'test', body: 'lorem ipsum', createdAt: Time.now, updatedAt: Time.now, :comments=>[{:content=>"C1"}, {:content=>"C2"}]
        }.to_s, @post_serializer.serializable_hash.to_s)
      end

      def test_attributes_serialization_using_upcase_key_conversion
        @post_serializer.convert_type = 'upcase'
        assert_match({
          TITLE: 'test', BODY: 'lorem ipsum', CREATED_AT: Time.now, UPDATED_AT: Time.now, :COMMENTS=>[{:content=>"C1"}, {:content=>"C2"}]
        }.to_s, @post_serializer.serializable_hash.to_s)
      end
    end

    class HelpersTest < ActiveModel::TestCase
      def setup
        @post = Post.new({ title: 'test', body: 'lorem ipsum', created_at: Time.now, updated_at: Time.now })
        @post_serializer = PostSerializer.new(@post)
      end

      def test_attributes_serialization_using_camelize_keys_helper
        @post_serializer.camelize_keys!
        assert_equal("camelcase", @post_serializer.convert_type)
      end

      def test_attributes_serialization_using_upcase_keys_helper
        @post_serializer.upcase_keys!
        assert_equal("upcase", @post_serializer.convert_type)
      end
    end
  end
end
