# To add grape support, require 'grape/active_model_serializers' in the base of your grape endpoints
# Then add 'formatter :json, Grape::Formatters::ActiveModelSerializers' to the endpoints
# Then add 'helpers Grape::Helpers::ActiveModelSerializers' to the endpoints
require 'active_model_serializers'
require 'grape/formatters/active_model_serializers'
require 'grape/helpers/active_model_serializers'
