module ActiveModel::Serializer::Integrations
  module RSpec
    class << self
      def serializers
        @serializers
      end

      def setup!
        @serializers = Hash.new(0)
      end
    end
  end
end

if defined?(::ActiveRecord) || defined?(::ActiveModel)
  require 'active_model/serializer/matchers'
  module RSpec::Matchers
    include Shoulda::ActiveModel::Serializer::Matchers
  end

  require 'active_model/serializer/assertions'
  RSpec.configure do |config|
    config.include ActiveModel::Serializer::Assertions, :type => :controller
    config.before :suite do
      ActiveSupport::Notifications.subscribe("render_serializer.active_model_serializers") do |_name, _start, _finish, _id, payload|
        ActiveModel::Serializer::Integrations::RSpec.serializers[payload[:serializer]] += 1
      end
    end
    config.after :suite do
      ActiveSupport::Notifications.unsubscribe("render_serialier.active_model_serializers")
    end
    config.before :each do
      ActiveModel::Serializer::Integrations::RSpec.setup!
    end
  end
end
