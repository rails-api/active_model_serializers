require 'test_helper'

module ActiveModel
  class Serializer
    class LoggingTest < ActiveSupport::TestCase
      class TestLogger < ActiveSupport::Logger
        def initialize
          @file = StringIO.new
          super(@file)
        end

        def messages
          @file.rewind
          @file.read
        end
      end

      def setup
        @author = Author.new(name: 'Steve K.')
        @post = Post.new(title: 'New Post', body: 'Body')
        @comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
        @post.comments = [@comment]
        @comment.post = @post
        @post.author = @author
        @author.posts = [@post]
        @post_serializer = PostSerializer.new(@post, custom_options: true)

        @old_logger = ActiveModelSerializers.logger
        @logger = ActiveSupport::TaggedLogging.new(TestLogger.new)
        logger @logger
      end

      def teardown
        logger @old_logger
      end

      def logger(logger)
        ActiveModelSerializers.logger = logger
      end

      test 'uses_ams_as_tag' do
        ActiveModelSerializers::SerializableResource.new(@post).serializable_hash
        assert_match(/\[active_model_serializers\]/, @logger.messages)
      end

      test 'logs_when_call_serializable_hash' do
        ActiveModelSerializers::SerializableResource.new(@post).serializable_hash
        assert_match(/Rendered/, @logger.messages)
      end

      test 'logs_when_call_as_json' do
        ActiveModelSerializers::SerializableResource.new(@post).as_json
        assert_match(/Rendered/, @logger.messages)
      end

      test 'logs_when_call_to_json' do
        ActiveModelSerializers::SerializableResource.new(@post).to_json
        assert_match(/Rendered/, @logger.messages)
      end

      test 'logs_correct_serializer' do
        ActiveModelSerializers::SerializableResource.new(@post).serializable_hash
        assert_match(/PostSerializer/, @logger.messages)
      end

      test 'logs_correct_adapter' do
        ActiveModelSerializers::SerializableResource.new(@post).serializable_hash
        assert_match(/ActiveModelSerializers::Adapter::Attributes/, @logger.messages)
      end

      test 'logs_the_duration' do
        ActiveModelSerializers::SerializableResource.new(@post).serializable_hash
        assert_match(/\(\d+\.\d+ms\)/, @logger.messages)
      end
    end
  end
end
