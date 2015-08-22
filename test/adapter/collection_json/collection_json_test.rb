require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class CollectionJson
        class CollectionJsonAdapterTest < Minitest::Test
          def setup
            @author = Author.new(id: 1, name: 'Carles J.')
            @first_post = Post.new(id: 1, title: 'Hello!!', body: 'Hello, world!!')
            @second_post = Post.new(id: 2, title: 'New Post', body: 'Body')

            @single_serializer = PostSerializer.new(@first_post)
            @multiple_serializer = ArraySerializer.new([@first_post, @second_post])

            Rails.application.routes.default_url_options[:host] = "localhost"
            Rails.application.routes.draw do
              resources :posts
            end
          end

          def test_response_with_a_single_resource
            adapter = ActiveModel::Serializer::Adapter::CollectionJson.new(@single_serializer)
            expected = {
              collection: {
                version: "1.0",
                href: "http://localhost/posts",
                items: [
                  {
                    href: "http://localhost/posts/1",
                    data: [{
                      name: "id", value: 1
                    },{
                      name: "title", value: "Hello!!"
                    },{
                      name: "body", value: "Hello, world!!"
                    }]
                  }
                ]
              }
            }

            assert_equal expected, adapter.serializable_hash
          end

          def test_response_with_multiple_resources
            adapter = ActiveModel::Serializer::Adapter::CollectionJson.new(@multiple_serializer)
            expected = {
              collection: {
                version: "1.0",
                href: "http://localhost/posts",
                items: [
                  {
                    href: "http://localhost/posts/1",
                    data: [{
                      name: "id", value: 1
                    },{
                      name: "title", value: "Hello!!"
                    },{
                      name: "body", value: "Hello, world!!"
                    }]
                  },
                  {
                    href: "http://localhost/posts/2",
                    data: [{
                      name: "id", value: 2
                    },{
                      name: "title", value: "New Post"
                    },{
                      name: "body", value: "Body"
                    }]
                  }
                ]
              }
            }

            assert_equal expected, adapter.serializable_hash
          end
        end
      end
    end
  end
end
