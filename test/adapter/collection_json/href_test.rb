require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class CollectionJson
        class Href< Minitest::Test
          def setup
            @author = Author.new(id: 1, name: 'Carles J.')
            @first_post = Post.new(
              id: 1,
              title: 'Hello!!',
              body: 'Hello, world!!'
            )
            @second_post = Post.new(id: 2, title: 'New Post', body: 'Body')

            @single_serializer = PostSerializer.new(@first_post)

            @multiple_serializer = ArraySerializer.
              new([@first_post, @second_post])

            Rails.application.routes.default_url_options[:host] = 'localhost'
            Rails.application.routes.draw do
              resources :posts
            end
          end

          def test_top_level_and_items_href_is_included_for_single_items
            adapter = ActiveModel::Serializer::Adapter::CollectionJson.
              new(@single_serializer)

            assert_equal "http://localhost/posts",
              adapter.serializable_hash[:collection][:href],
              "top-level href does not match"
            assert_equal "http://localhost/posts/1",
              adapter.serializable_hash[:collection][:items][0][:href],
              "item href does not match"
          end
        end
      end
    end
  end
end
