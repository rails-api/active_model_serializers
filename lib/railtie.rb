require 'active_model_serializers'
require 'action_controller/serialization'

module ActiveModel
  module Serialization
    class Railtie < ::Rails::Railtie
      initializer "active_model.serialization.action_controller" do
        ActiveSupport.on_load(:action_controller) do
          include ::ActionController::Serilization
        end
      end
    end
  end
end
