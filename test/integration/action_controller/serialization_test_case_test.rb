require 'test_helper'

module ActionController
  module SerializationsAssertions
    class RenderSerializerTest < ActionController::TestCase
      class MyController < ActionController::Base
        def render_using_serializer
          render json: Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        end

        def render_text
          render text: 'ok'
        end

        def render_template
          prepend_view_path "./test/fixtures"
          render template: "template"
        end
      end

      tests MyController

      def test_supports_specifying_serializers_with_a_serializer_class
        get :render_using_serializer
        assert_serializer ProfileSerializer
      end

      def test_supports_specifying_serializers_with_a_regexp
        get :render_using_serializer
        assert_serializer %r{\AProfile.+\Z}
      end

      def test_supports_specifying_serializers_with_a_string
        get :render_using_serializer
        assert_serializer 'ProfileSerializer'
      end

      def test_supports_specifying_serializers_with_a_symbol
        get :render_using_serializer
        assert_serializer :profile_serializer
      end

      def test_supports_specifying_serializers_with_a_nil
        get :render_text
        assert_serializer nil
      end

      def test_raises_descriptive_error_message_when_serializer_was_not_rendered
        get :render_using_serializer
        e = assert_raise ActiveSupport::TestCase::Assertion do
          assert_serializer 'PostSerializer'
        end
        assert_match 'expecting <"PostSerializer"> but rendering with <["ProfileSerializer"]>', e.message
      end


      def test_raises_argument_error_when_asserting_with_invalid_object
        get :render_using_serializer
        e = assert_raise ArgumentError do
          assert_serializer Hash
        end
        assert_match 'assert_serializer only accepts a String, Symbol, Regexp, ActiveModel::Serializer, or nil', e.message
      end

      def test_does_not_overwrite_notification_subscriptions
        get :render_template
        assert_template "template"
      end
    end
  end
end
