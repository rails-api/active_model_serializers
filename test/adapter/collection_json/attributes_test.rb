require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class CollectionJson
        class Attributes < Minitest::Test
          def setup
            @author = Author.new(id: 1, name: 'Carles J.')
            @first_post = Post.new(id: 1, title: 'Hello!', body: 'Hello, world!!')
            @second_post = Post.new(id: 2, title: 'New Post', body: 'Body')

            @single_serializer = PostSerializer.new(@first_post)
            @multiple_serializer = ArraySerializer.new([@first_post, @second_post])

            Rails.application.routes.default_url_options[:host] = 'localhost'
            Rails.application.routes.draw do
              resources :posts
            end
          end

          def test_a_single_post_is_included
            adapter = ActiveModel::Serializer::Adapter::CollectionJson.
              new(@single_serializer)
            expected = [
              { name: "id", value: 1 },
              { name: "title", value: "Hello!" },
              { name: "body", value: "Hello, world!!" }
            ]

            assert_equal expected,
                         adapter.serializable_hash[:collection][:items][0][:data]
          end

          def test_multiple_posts_are_included
            adapter = ActiveModel::Serializer::Adapter::CollectionJson.
              new(@multiple_serializer)
            expected_1 = [
              { name: "id", value: 1 },
              { name: "title", value: "Hello!" },
              { name: "body", value: "Hello, world!!" }
            ]
            expected_2 = [
              { name: "id", value: 2 },
              { name: "title", value: "New Post" },
              { name: "body", value: "Body" }
            ]


            assert_equal expected_1,
                         adapter.serializable_hash[:collection][:items][0][:data]
            assert_equal expected_2,
                         adapter.serializable_hash[:collection][:items][1][:data]

          end

        end
      end
    end
  end
end
