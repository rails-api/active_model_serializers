require 'test_helper'

module ActiveModel
  class Serializer
    class Adapter
      class JsonApi
        class TopLevelLinksTest < Minitest::Test
          URI = 'http://example.com'

          def setup
            ActionController::Base.cache_store.clear
            @blog = Blog.new(id: 1,
                             name: 'AMS Hints',
                             writer: Author.new(id: 2, name: "Steve"),
                             articles: [Post.new(id: 3, title: "AMS")])
          end

          def load_adapter(paginated_collection, options = {})
            options = options.merge(adapter: :json_api)
            ActiveModel::SerializableResource.new(paginated_collection, options)
          end

          def test_links_is_not_present_when_not_defined
            adapter = load_adapter(@blog)

            expected = {
              :data => {
                :id => "1",
                :type => "blogs",
                :attributes => {
                  :name => "AMS Hints"
                },
                :relationships => {
                  :writer=> {:data => {:type => "authors", :id => "2"}},
                  :articles => {:data => [{:type => "posts", :id => "3"}]}
               }
            }}

            assert_equal expected, adapter.serializable_hash(@options)
          end

          def test_links_is_present_when_defined
            adapter = load_adapter(@blog, {links: links})

            expected = {
              :data => {
                :id => "1",
                :type => "blogs",
                :attributes => {
                  :name => "AMS Hints"
                },
                :relationships => {
                  :writer=> {:data => {:type => "authors", :id => "2"}},
                  :articles => {:data => [{:type => "posts", :id => "3"}]}
               }
              },
               :links => {:self => "http://example.com/blogs/1"}
            }

            assert_equal expected, adapter.serializable_hash(@options)
          end

          def links
            {
              self: "#{URI}/blogs/1"
            }
          end

          # def test_links_is_not_present_when_not_declared
          #   serializer = AlternateBlogSerializer.new(@blog)
          #   adapter = ActiveModel::Serializer::Adapter::JsonApi.new(serializer)
          #   expected = {
          #     data: {
          #       id: "1",
          #       type: "blogs",
          #       attributes: {
          #         title: "AMS Hints"
          #       }
          #     }
          #   }
          #   assert_equal expected, adapter.as_json
          # end

          # def test_links_is_not_present_on_flattenjson_adapter
          #   serializer = AlternateBlogSerializer.new(@blog, :links => {:self => "/blogs/1"})
          #   adapter = ActiveModel::Serializer::Adapter::FlattenJson.new(serializer)
          #   expected = {:id=>1, :title=>"AMS Hints"}
          #   assert_equal expected, adapter.as_json
          # end

          # def test_links_is_not_present_on_json_adapter
          #   serializer = AlternateBlogSerializer.new(@blog, :links => {:self => "/blogs/1"})
          #   adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)
          #   expected = {:blog=>{:id=>1, :title=>"AMS Hints"}}
          #   assert_equal expected, adapter.as_json
          # end
        end
      end
    end
  end
end
