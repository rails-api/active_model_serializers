##
# Adapted from:
#   https://github.com/rails/rails/blob/280654ef88/activejob/lib/active_job/logging.rb
module ActiveModelSerializers::Logging
  extend ActiveSupport::Concern

  included do
    extend ActiveModel::Callbacks
    define_model_callbacks :render
    around_render do |_, block, _|
      notify_active_support do
        block.call
      end
    end
  end

  def notify_active_support
    event_name = 'render.active_model_serializers'.freeze
    payload = { serializer: serializer, adapter: adapter }
    ActiveSupport::Notifications.instrument(event_name, payload) do
      yield
    end
  end

  private

  class LogSubscriber < ActiveSupport::LogSubscriber
    def render(event)
      logger.tagged('AMS') do
        info do
          serializer = event.payload[:serializer]
          adapter = event.payload[:adapter]
          duration = event.duration.round(2)
          "Rendered #{serializer.name} with #{adapter.class} (#{duration}ms)"
        end
      end
    end

    def logger
      ActiveModelSerializers.logger
    end
  end
end

ActiveModelSerializers::Logging::LogSubscriber.attach_to :active_model_serializers
