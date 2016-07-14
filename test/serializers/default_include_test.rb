require 'test_helper'

module ActiveModel
  class Serializer
    class DefaultIncludeTest < ActiveSupport::TestCase
      class Blog < ActiveModelSerializers::Model
        attr_accessor :id, :name, :posts
      end
      class Post < ActiveModelSerializers::Model
        attr_accessor :id, :title, :author, :category
      end
      class Author < ActiveModelSerializers::Model
        attr_accessor :id, :name
      end
      class Category < ActiveModelSerializers::Model
        attr_accessor :id, :name
      end

      class BlogSerializer < ActiveModel::Serializer
        default_include 'posts.author'
        attributes :id
        attribute :name, key: :title

        has_many :posts
      end
      class PostSerializer < ActiveModel::Serializer
        default_include 'author'
        attributes :id, :title

        has_one :author
        has_one :category
      end
      class AuthorSerializer < ActiveModel::Serializer
        attributes :id, :name
      end
      class CategorySerializer < ActiveModel::Serializer
        attributes :id, :name
      end

      setup do
        @authors = [Author.new(id: 1, name: 'Blog Author')]
        @categories = [Category.new(id: 1, name: 'Food')]
        @posts = [
            Post.new(id: 1, title: 'The first post', author: @authors.first, category: @categories.first),
            Post.new(id: 2, title: 'The second post', author: @authors.first, category: @categories.first)]
        @blog = Blog.new(id: 2, name: 'The Blog', posts: @posts)
      end

      test '#default_include option populate "included" for json_api adapter' do
        serialized = serializable(@blog, serializer: BlogSerializer, adapter: :json_api).as_json

        assert_equal serialized[:included].size, 3
        assert_equal 'The first post', serialized[:included].first[:attributes][:title]
      end

      test '#default_include merges with the render include for json_api adapter' do
        serialized = serializable(@blog, serializer: BlogSerializer, adapter: :json_api, include: 'posts.category').as_json

        assert_equal serialized[:included].size, 4
        assert_equal 'The first post', serialized[:included].first[:attributes][:title]
      end

      test '#default_include option include associations for attributes adapter' do
        serialized = serializable(@blog, serializer: BlogSerializer, adapter: :attributes).as_json

        assert_equal serialized[:posts].size, 2
        assert_equal 'Blog Author', serialized[:posts].first[:author][:name]
      end

      test '#default_include merges with the render include for attributes adapter' do
        serialized = serializable(@blog, serializer: BlogSerializer, adapter: :attributes, include: 'posts.category').as_json

        assert_equal serialized[:posts].size, 2
        assert_equal 'Blog Author', serialized[:posts].first[:author][:name]
        assert_equal 'Food', serialized[:posts].first[:category][:name]
      end
    end
  end
end
