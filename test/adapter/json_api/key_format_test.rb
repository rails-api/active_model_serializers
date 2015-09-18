require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
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
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer)
          end

          def test_dasherizes_keys_by_default
            assert @adapter.serializable_hash[:data][:attributes].key?(:'multi-word-attribute')
            assert @adapter.serializable_hash[:data][:relationships].key?(:'tons-of-comments')
            assert @adapter.serializable_hash[:data][:relationships].key?(:'stoic-author')
          end

          def test_accepts_adapter_override
            @adapter = ActiveModel::Serializer::Adapter::JsonApi.new(@serializer, key_format: :lower_camel)

            assert @adapter.serializable_hash[:data][:attributes].key?(:'multiWordAttribute')
            assert @adapter.serializable_hash[:data][:relationships].key?(:'tonsOfComments')
            assert @adapter.serializable_hash[:data][:relationships].key?(:'stoicAuthor')
          end
        end
      end
    end
  end
end
