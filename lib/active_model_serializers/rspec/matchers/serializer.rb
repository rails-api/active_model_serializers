require 'active_model_serializers/test/serializer'

module ActiveModelSerializers
  module RSpecMatchers
    module Serializer
      extend ActiveModelSerializers::Test::Serializer
      extend ActiveSupport::Concern

      included do
        setup :setup_serialization_subscriptions
        teardown :teardown_serialization_subscriptions

        RSpec::Matchers.define :use_serializer do |expected|
          match do
            serializer_matches?(expected)
          end
          failure_message do
            message
          end
        end
      end

      def serializer_matches?(expectation)
        @assert_serializer.expectation = expectation
        @assert_serializer.message = message
        @assert_serializer.response = response
        @assert_serializer.matches?
      end

      def message
        @assert_serializer.message
      end

      class Base < ActiveModelSerializers::Test::Serializer::AssertSerializer
        def subscribe
          @_subscribers << ActiveSupport::Notifications.subscribe(event_name) do |_name, _start, _finish, _id, payload|
            serializer = payload[:serializer].name
            serializers << serializer
            next unless serializer == 'ActiveModel::Serializer::CollectionSerializer'
            serializers << payload[:adapter].serializer.send(:options)[:serializer].name
          end
        end
      end

      private

      def setup_serialization_subscriptions
        @assert_serializer = Base.new
        @assert_serializer.subscribe
      end

      def teardown_serialization_subscriptions
        @assert_serializer.unsubscribe
      end
    end
  end
end
