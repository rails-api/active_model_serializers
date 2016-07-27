require 'test_helper'

module ActiveModelSerializers
  module Test
    class SerializerTest < ActionController::TestCase
      include ActiveModelSerializers::Test::Serializer

      class MyController < ActionController::Base
        def render_using_serializer
          render json: Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
        end

        def render_some_text
          render(plain: 'ok')
        end
      end

      tests MyController

      test 'supports_specifying_serializers_with_a_serializer_class' do
        get :render_using_serializer
        assert_serializer ProfileSerializer
      end

      test 'supports_specifying_serializers_with_a_regexp' do
        get :render_using_serializer
        assert_serializer(/\AProfile.+\Z/)
      end

      test 'supports_specifying_serializers_with_a_string' do
        get :render_using_serializer
        assert_serializer 'ProfileSerializer'
      end

      test 'supports_specifying_serializers_with_a_symbol' do
        get :render_using_serializer
        assert_serializer :profile_serializer
      end

      test 'supports_specifying_serializers_with_a_nil' do
        get :render_some_text
        assert_serializer nil
      end

      test 'raises_descriptive_error_message_when_serializer_was_not_rendered' do
        get :render_using_serializer
        e = assert_raise ActiveSupport::TestCase::Assertion do
          assert_serializer 'PostSerializer'
        end
        assert_match 'expecting <"PostSerializer"> but rendering with <["ProfileSerializer"]>', e.message
      end

      test 'raises_argument_error_when_asserting_with_invalid_object' do
        get :render_using_serializer
        e = assert_raise ArgumentError do
          assert_serializer Hash
        end
        assert_match 'assert_serializer only accepts a String, Symbol, Regexp, ActiveModel::Serializer, or nil', e.message
      end
    end
  end
end
