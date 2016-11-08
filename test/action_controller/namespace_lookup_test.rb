require 'test_helper'

module ActionController
  module Serialization
    class NamespaceLookupTest < ActionController::TestCase
      class Book < ::Model; end
      class Page < ::Model; end
      class Writer < ::Model; end

      module Api
        module V2
          class BookSerializer < ActiveModel::Serializer
            attributes :title
          end
        end

        module V3
          class BookSerializer < ActiveModel::Serializer
            attributes :title, :body

            belongs_to :writer
          end

          class WriterSerializer < ActiveModel::Serializer
            attributes :name
          end

          class LookupTestController < ActionController::Base
            before_action only: [:namespace_set_in_before_filter] do
              self.namespace_for_serializer = Api::V2
            end

            def implicit_namespaced_serializer
              writer = Writer.new(name: 'Bob')
              book = Book.new(title: 'New Post', body: 'Body', writer: writer)

              render json: book
            end

            def explicit_namespace_as_module
              book = Book.new(title: 'New Post', body: 'Body')

              render json: book, namespace: Api::V2
            end

            def explicit_namespace_as_string
              book = Book.new(title: 'New Post', body: 'Body')

              # because this is a string, ruby can't auto-lookup the constant, so otherwise
              # the looku things we mean ::Api::V2
              render json: book, namespace: 'ActionController::Serialization::NamespaceLookupTest::Api::V2'
            end

            def explicit_namespace_as_symbol
              book = Book.new(title: 'New Post', body: 'Body')

              # because this is a string, ruby can't auto-lookup the constant, so otherwise
              # the looku things we mean ::Api::V2
              render json: book, namespace: :'ActionController::Serialization::NamespaceLookupTest::Api::V2'
            end

            def invalid_namespace
              book = Book.new(title: 'New Post', body: 'Body')

              render json: book, namespace: :api_v2
            end

            def namespace_set_in_before_filter
              book = Book.new(title: 'New Post', body: 'Body')
              render json: book
            end
          end
        end
      end

      tests Api::V3::LookupTestController

      setup do
        @test_namespace = self.class.parent
      end

      test 'implicitly uses namespaced serializer' do
        get :implicit_namespaced_serializer

        assert_serializer Api::V3::BookSerializer

        expected = { 'title' => 'New Post', 'body' => 'Body', 'writer' => { 'name' => 'Bob' } }
        actual = JSON.parse(@response.body)

        assert_equal expected, actual
      end

      test 'explicit namespace as module' do
        get :explicit_namespace_as_module

        assert_serializer Api::V2::BookSerializer

        expected = { 'title' => 'New Post' }
        actual = JSON.parse(@response.body)

        assert_equal expected, actual
      end

      test 'explicit namespace as string' do
        get :explicit_namespace_as_string

        assert_serializer Api::V2::BookSerializer

        expected = { 'title' => 'New Post' }
        actual = JSON.parse(@response.body)

        assert_equal expected, actual
      end

      test 'explicit namespace as symbol' do
        get :explicit_namespace_as_symbol

        assert_serializer Api::V2::BookSerializer

        expected = { 'title' => 'New Post' }
        actual = JSON.parse(@response.body)

        assert_equal expected, actual
      end

      test 'invalid namespace' do
        get :invalid_namespace

        assert_serializer ActiveModel::Serializer::Null

        expected = { 'title' => 'New Post', 'body' => 'Body' }
        actual = JSON.parse(@response.body)

        assert_equal expected, actual
      end

      test 'namespace set in before filter' do
        get :namespace_set_in_before_filter

        assert_serializer Api::V2::BookSerializer

        expected = { 'title' => 'New Post' }
        actual = JSON.parse(@response.body)

        assert_equal expected, actual
      end
    end
  end
end
