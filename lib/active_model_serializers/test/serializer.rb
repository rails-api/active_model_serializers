module ActiveModelSerializers
  module Test
    module Serializer
      extend ActiveSupport::Concern

      included do
        setup :setup_serialization_subscriptions
        teardown :teardown_serialization_subscriptions
      end

      # Asserts that the request was rendered with the appropriate serializers.
      #
      #  # assert that the "PostSerializer" serializer was rendered
      #  assert_serializer "PostSerializer"
      #
      #  # return a custom error message
      #  assert_serializer "PostSerializer", "PostSerializer not rendered"
      #
      #  # assert that the instance of PostSerializer was rendered
      #  assert_serializer PostSerializer
      #
      #  # assert that the "PostSerializer" serializer was rendered
      #  assert_serializer :post_serializer
      #
      #  # assert that the rendered serializer starts with "Post"
      #  assert_serializer %r{\APost.+\Z}
      #
      #  # assert that no serializer was rendered
      #  assert_serializer nil
      #
      def assert_serializer(expectation, message = nil)
        # Force body to be read in case the template is being streamed.
        response.body

        msg = message || "expecting <#{expectation.inspect}> but rendering with <#{serializers}>"

        matches_serializer = case expectation
                             when a_serializer?
                               matches_class?(expectation)
                             when Symbol
                               matches_symbol?(expectation)
                             when String
                               matches_string?(expectation)
                             when Regexp
                               matches_regexp?(expectation)
                             when NilClass
                               matches_nil?
                             else
                               fail ArgumentError, 'assert_serializer only accepts a String, Symbol, Regexp, ActiveModel::Serializer, or nil'
                             end
        assert(matches_serializer, msg)
      end

      private

      ActiveModelSerializers.silence_warnings do
        attr_reader :serializers, :expectation
      end

      def setup_serialization_subscriptions
        @serializers = []
        ActiveSupport::Notifications.subscribe(event_name) do |_name, _start, _finish, _id, payload|
          serializer = payload[:serializer].name
          serializers << serializer
        end
      end

      def teardown_serialization_subscriptions
        ActiveSupport::Notifications.unsubscribe(event_name)
      end

      def event_name
        'render.active_model_serializers'
      end

      def matches_class?(expectation)
        serializers.include?(expectation.name)
      end

      def matches_symbol?(expectation)
        expectation = expectation.to_s.camelize
        serializers.include?(expectation)
      end

      def matches_string?(expectation)
        !expectation.empty? && serializers.include?(expectation)
      end

      def matches_regexp?(expectation)
        serializers.any? do |serializer|
          serializer.match(expectation)
        end
      end

      def matches_nil?
        serializers.blank?
      end

      def a_serializer?
        ->(exp) { exp.is_a?(Class) && exp < ActiveModel::Serializer }
      end
    end
  end
end
