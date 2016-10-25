require 'rails'
require 'action_controller'
require 'action_controller/test_case'
require 'active_model_serializers'

$LOAD_PATH.unshift File.expand_path('../../test', __FILE__)
require 'support/rails_app'
require 'fixtures/active_record'
require 'fixtures/poro'

require 'rspec/rails'
require 'active_model_serializers/rspec'
