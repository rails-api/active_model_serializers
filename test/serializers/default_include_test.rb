require 'test_helper'

module ActiveModel
  class Serializer
    class DefaultIncludeTest < ActiveSupport::TestCase
      class Blog < ActiveModelSerializers::Model
        attr_accessor :id, :name, :posts
      end
      class Post < ActiveModelSerializers::Model
        attr_accessor :id, :title, :author
      end
      class Author < ActiveModelSerializers::Model
        attr_accessor :id, :name
      end
      class BlogSerializer < ActiveModel::Serializer
        attributes :id
        attribute :name, key: :title

        has_many :posts
      end
      class PostSerializer < ActiveModel::Serializer
        default_include [:author]
        attributes :id, :title

        has_one :author
      end
      class AuthorSerializer < ActiveModel::Serializer
        attributes :id, :name
      end

      setup do
        @authors = [Author.new(id: 1, name: 'Blog Author')]
        @posts = [Post.new(id: 1, title: 'The first post', author: @authors.first), Post.new(id: 2, title: 'The second post', author: @authors.first)]
        @blog = Blog.new(id: 2, name: 'The Blog', posts: @posts)
        @serializer_instance = BlogSerializer.new(@blog)
        @serializable = ActiveModelSerializers::SerializableResource.new(@blog, serializer: BlogSerializer, adapter: :attributes)
        @expected_hash = {
            id: 2,
            title: 'The Blog',
            posts: [
                { id: 1, title: 'The first post', author: { id: 1, name: 'Blog Author'} },
                { id: 2, title: 'The second post', author: { id: 1, name: 'Blog Author'} }
            ] }
      end

      test '#default_include allows to include associations in the result of #serializable_hash' do
        assert_equal @serializable.serializable_hash, @serializer_instance.serializable_hash
        assert_equal @expected_hash, @serializer_instance.serializable_hash
      end
    end
  end
end
