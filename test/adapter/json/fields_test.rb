# frozen_string_literal: true

require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class Json
      class FieldsTest < ActiveSupport::TestCase
        class Post < ::Model
          attributes :title, :body
          associations :author, :comments
        end
        class Author < ::Model
          attributes :name, :birthday
        end
        class Comment < ::Model
          attributes :title, :body
          associations :author, :post
        end

        class PostSerializer < ActiveModel::Serializer
          type 'post'
          attributes :title, :body
          belongs_to :author
          has_many :comments
        end

        class AuthorSerializer < ActiveModel::Serializer
          attributes :name, :birthday
        end

        class CommentSerializer < ActiveModel::Serializer
          type 'comment'
          attributes :title, :body
          belongs_to :author
        end

        def setup
          @author = Author.new(id: 1, name: 'Lucas', birthday: '10.01.1990')
          @comment1 = Comment.new(id: 7, body: 'cool', author: @author)
          @comment2 = Comment.new(id: 12, body: 'awesome', author: @author)
          @post = Post.new(id: 1337, title: 'Title 1', body: 'Body 1',
                           author: @author, comments: [@comment1, @comment2])
          @comment1.post = @post
          @comment2.post = @post
        end

        def test_fields_attributes
          fields = [:title]
          hash = serializable(@post, adapter: :json, fields: fields, include: []).serializable_hash
          expected = { title: 'Title 1' }
          assert_equal(expected, hash[:post])
        end

        def test_fields_included
          fields = [:title, { comments: [:body] }]
          hash = serializable(@post, adapter: :json, include: [:comments], fields: fields).serializable_hash
          expected = [{ body: @comment1.body }, { body: @comment2.body }]

          assert_equal(expected, hash[:post][:comments])
        end
      end
    end
  end
end
