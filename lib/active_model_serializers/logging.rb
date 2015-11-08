##
# Adapted from:
#   https://github.com/rails/rails/blob/280654ef88/activejob/lib/active_job/logging.rb
module ActiveModelSerializers::Logging
  def self.included(base)
    base.send(:include, ActiveSupport::Callbacks)
    base.extend ClassMethods
    base.class_eval do
      define_callbacks :render
      around_render do |_, block|
        notify_active_support do
          block.call
        end
      end
    end
  end

  module ClassMethods
    def around_render(*filters, &blk)
      set_callback(:render, :around, *filters, &blk)
    end
    ##
    # Simple notify method that wraps up +name+
    # in a dummy method. It notifies on each call to the dummy method
    # telling what the current serializer and adapter are being rendered.
    # Adapted from:
    #   https://github.com/rubygems/rubygems/blob/cb28f5e991/lib/rubygems/deprecate.rb

    def notify(name, callback_name)
      class_eval do
        old = "_notifying_#{callback_name}_#{name}"
        alias_method old, name
        define_method name do |*args, &block|
          run_callbacks callback_name do
            send old, *args, &block
          end
        end
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
