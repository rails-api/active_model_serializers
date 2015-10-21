module ActiveModel
  class Serializer
    module Logging
      extend ActiveSupport::Concern

      included do
        cattr_accessor(:logger) do
          ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))
        end
      end

      class LogSubscriber < ActiveSupport::LogSubscriber
        def render(event)
          serializer = event.payload[:serializer]
          adapter = event.payload[:adapter]
          duration = event.duration.round(2)
          logger.tagged('AMS') do
            info do
              "Rendered #{serializer.name} with #{adapter.class} (#{duration}ms)"
            end
          end
        end

        def logger
          ActiveModel::Serializer.logger
        end
      end
    end
  end
end

ActiveModel::Serializer::Logging::LogSubscriber.attach_to :active_model_serializers
