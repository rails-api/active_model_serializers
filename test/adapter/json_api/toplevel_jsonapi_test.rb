require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi
      class TopLevelJsonApiTest < ActiveSupport::TestCase
        def setup
          @author = Author.new(id: 1, name: 'Steve K.')
          @author.bio = nil
          @author.roles = []
          @blog = Blog.new(id: 23, name: 'AMS Blog')
          @post = Post.new(id: 42, title: 'New Post', body: 'Body')
          @anonymous_post = Post.new(id: 43, title: 'Hello!!', body: 'Hello, world!!')
          @comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
          @post.comments = [@comment]
          @post.blog = @blog
          @anonymous_post.comments = []
          @anonymous_post.blog = nil
          @comment.post = @post
          @comment.author = nil
          @post.author = @author
          @anonymous_post.author = nil
          @blog = Blog.new(id: 1, name: 'My Blog!!')
          @blog.writer = @author
          @blog.articles = [@post, @anonymous_post]
          @author.posts = []
        end

        test 'toplevel_jsonapi_defaults_to_false' do
          assert_equal config.fetch(:jsonapi_include_toplevel_object), false
        end

        test 'disable_toplevel_jsonapi' do
          with_config(jsonapi_include_toplevel_object: false) do
            hash = serialize(@post)
            assert_nil(hash[:jsonapi])
          end
        end

        test 'enable_toplevel_jsonapi' do
          with_config(jsonapi_include_toplevel_object: true) do
            hash = serialize(@post)
            refute_nil(hash[:jsonapi])
          end
        end

        test 'default_toplevel_jsonapi_version' do
          with_config(jsonapi_include_toplevel_object: true) do
            hash = serialize(@post)
            assert_equal('1.0', hash[:jsonapi][:version])
          end
        end

        test 'toplevel_jsonapi_no_meta' do
          with_config(jsonapi_include_toplevel_object: true) do
            hash = serialize(@post)
            assert_nil(hash[:jsonapi][:meta])
          end
        end

        test 'toplevel_jsonapi_meta' do
          new_config = {
            jsonapi_include_toplevel_object: true,
            jsonapi_toplevel_meta: {
              'copyright' => 'Copyright 2015 Example Corp.'
            }
          }
          with_config(new_config) do
            hash = serialize(@post)
            assert_equal(new_config[:jsonapi_toplevel_meta], hash.fetch(:jsonapi).fetch(:meta))
          end
        end

        private

        def serialize(resource, options = {})
          serializable(resource, { adapter: :json_api }.merge!(options)).serializable_hash
        end
      end
    end
  end
end
