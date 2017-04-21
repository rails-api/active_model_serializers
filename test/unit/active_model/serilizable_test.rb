require 'test_helper'

module ActiveModel
  class SerializableTest
    class InstrumentationTest < Minitest::Test
      def setup
        @events = []

        @subscriber = ActiveSupport::Notifications.subscribe('!serialize.active_model_serializers') do |name, start, finish, id, payload|
          @events << { name: name, serializer: payload[:serializer] }
        end
      end

      def teardown
        ActiveSupport::Notifications.unsubscribe(@subscriber) if defined?(@subscriber)
      end

      def test_instruments_default_serializer
        DefaultSerializer.new(1).as_json

        assert_equal [{ name: '!serialize.active_model_serializers', serializer: 'ActiveModel::DefaultSerializer' }], @events
      end

      def test_instruments_serializer
        profile = Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
        serializer = ProfileSerializer.new(profile)

        serializer.as_json

        assert_equal [{ name: '!serialize.active_model_serializers', serializer: 'ProfileSerializer' }], @events
      end

      def test_instruments_array_serializer
        profiles = [
          Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1'),
          Profile.new(name: 'Name 2', description: 'Description 2', comments: 'Comments 2')
        ]
        serializer = ArraySerializer.new(profiles)

        serializer.as_json

        assert_equal [
          { name: '!serialize.active_model_serializers', serializer: 'ProfileSerializer' },
          { name: '!serialize.active_model_serializers', serializer: 'ProfileSerializer' },
          { name: '!serialize.active_model_serializers', serializer: 'ActiveModel::ArraySerializer' }
        ], @events
      end
    end
  end
end
