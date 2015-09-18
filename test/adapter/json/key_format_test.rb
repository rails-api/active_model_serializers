require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class Json
        class KeyFormatTest < Minitest::Test
          def setup
            @author = Author.new(name: 'Steve K.')

            @first_post = Post.new(
              id:                   1,
              title:                'Hello!!',
              body:                 'Hello, world!!',
              multi_word_attribute: 'Something about hello')
            @second_post = Post.new(
              id:                   2,
              title:                'New Post',
              body:                 'Body',
              multi_word_attribute: 'Something about new')

            @author.posts = [@first_post, @second_post]

            @first_post.author = @author
            @second_post.author = @author

            @first_post.comments = []
            @second_post.comments = []

            @serializer = PostWithMultiWordKeysSerializer.new(@first_post)
            @adapter = ActiveModel::Serializer::Adapter::Json.new(@serializer)
          end

          def test_camelizes_keys_by_default
            assert @adapter.serializable_hash[:post].key?(:multiWordAttribute)
            assert @adapter.serializable_hash[:post].key?(:tonsOfComments)
            assert @adapter.serializable_hash[:post].key?(:stoicAuthor)
          end

          def test_accepts_adapter_override
            @adapter = ActiveModel::Serializer::Adapter::Json.new(@serializer, key_format: :underscore)

            assert @adapter.serializable_hash[:post].key?(:multi_word_attribute)
            assert @adapter.serializable_hash[:post].key?(:tons_of_comments)
            assert @adapter.serializable_hash[:post].key?(:stoic_author)
          end

          def test_accepts_global_override
            ActiveModel::Serializer.config.key_format = :underscore

            assert @adapter.serializable_hash[:post].key?(:multi_word_attribute)
            assert @adapter.serializable_hash[:post].key?(:tons_of_comments)
            assert @adapter.serializable_hash[:post].key?(:stoic_author)

            ActiveModel::Serializer.config.key_format = nil
          end
        end
      end
    end
  end
end
