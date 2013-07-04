require 'newbase/active_model/serializer'
require 'newbase/active_model/serializer_support'

begin
  require 'action_controller'
  require 'newbase/action_controller/serialization'

  ActiveSupport.on_load(:action_controller) do
    include ::ActionController::Serialization
  end
rescue LoadError
  # rails not installed, continuing
end

[:active_record, :mongoid].each do |orm|
  ActiveSupport.on_load(orm) do
    include ActiveModel::SerializerSupport
  end
end
