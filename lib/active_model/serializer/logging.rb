module ActiveModel
  class Serializer
    module Logging
      extend ActiveSupport::Concern

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
  end
end

ActiveModel::Serializer::Logging::LogSubscriber.attach_to :active_model_serializers
