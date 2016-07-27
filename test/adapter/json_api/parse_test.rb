require 'test_helper'
module ActiveModelSerializers
  module Adapter
    class JsonApi
      module Deserialization
        class ParseTest < Minitest::Test
          def setup
            @hash = {
              'data' => {
                'type' => 'photos',
                'id' => 'zorglub',
                'attributes' => {
                  'title' => 'Ember Hamster',
                  'src' => 'http://example.com/images/productivity.png'
                },
                'relationships' => {
                  'author' => {
                    'data' => nil
                  },
                  'photographer' => {
                    'data' => { 'type' => 'people', 'id' => '9' }
                  },
                  'comments' => {
                    'data' => [
                      { 'type' => 'comments', 'id' => '1' },
                      { 'type' => 'comments', 'id' => '2' }
                    ]
                  }
                }
              }
            }
            @params = ActionController::Parameters.new(@hash)
            @expected = {
              id: 'zorglub',
              title: 'Ember Hamster',
              src: 'http://example.com/images/productivity.png',
              author_id: nil,
              photographer_id: '9',
              comment_ids: %w(1 2)
            }

            @illformed_payloads = [nil,
                                   {},
                                   {
                                     'data' => nil
                                   }, {
                                     'data' => { 'attributes' => [] }
                                   }, {
                                     'data' => { 'relationships' => [] }
                                   }, {
                                     'data' => {
                                       'relationships' => { 'rel' => nil }
                                     }
                                   }, {
                                     'data' => {
                                       'relationships' => { 'rel' => {} }
                                     }
                                   }]
          end

          test 'hash' do
            parsed_hash = ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse!(@hash)
            assert_equal(@expected, parsed_hash)
          end

          test 'actioncontroller_parameters' do
            assert_equal(false, @params.permitted?)
            parsed_hash = ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse!(@params)
            assert_equal(@expected, parsed_hash)
          end

          test 'illformed_payloads_safe' do
            @illformed_payloads.each do |p|
              parsed_hash = ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse(p)
              assert_equal({}, parsed_hash)
            end
          end

          test 'illformed_payloads_unsafe' do
            @illformed_payloads.each do |p|
              assert_raises(InvalidDocument) do
                ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse!(p)
              end
            end
          end

          test 'filter_fields_only' do
            parsed_hash = ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse!(@hash, only: [:id, :title, :author])
            expected = {
              id: 'zorglub',
              title: 'Ember Hamster',
              author_id: nil
            }
            assert_equal(expected, parsed_hash)
          end

          test 'filter_fields_except' do
            parsed_hash = ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse!(@hash, except: [:id, :title, :author])
            expected = {
              src: 'http://example.com/images/productivity.png',
              photographer_id: '9',
              comment_ids: %w(1 2)
            }
            assert_equal(expected, parsed_hash)
          end

          test 'keys' do
            parsed_hash = ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse!(@hash, keys: { author: :user, title: :post_title })
            expected = {
              id: 'zorglub',
              post_title: 'Ember Hamster',
              src: 'http://example.com/images/productivity.png',
              user_id: nil,
              photographer_id: '9',
              comment_ids: %w(1 2)
            }
            assert_equal(expected, parsed_hash)
          end

          test 'polymorphic' do
            parsed_hash = ActiveModelSerializers::Adapter::JsonApi::Deserialization.parse!(@hash, polymorphic: [:photographer])
            expected = {
              id: 'zorglub',
              title: 'Ember Hamster',
              src: 'http://example.com/images/productivity.png',
              author_id: nil,
              photographer_id: '9',
              photographer_type: 'people',
              comment_ids: %w(1 2)
            }
            assert_equal(expected, parsed_hash)
          end
        end
      end
    end
  end
end
