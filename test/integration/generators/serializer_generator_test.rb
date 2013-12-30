require 'test_helper'
require 'rails'
require 'active_model/serializer/railtie'
require 'test_app'

class SerializerGeneratorTest < Rails::Generators::TestCase
  destination File.expand_path('../../../tmp', __FILE__)
  setup :prepare_destination

  tests Rails::Generators::SerializerGenerator
  arguments %w(account name:string description:text business:references)

  def test_generates_a_serializer_with_attributes_and_associations
    run_generator
    assert_file 'app/serializers/account_serializer.rb', /class AccountSerializer < ActiveModel::Serializer/ do |serializer|
      assert_match(/attributes :id, :name, :description/, serializer)
      assert_match(/has_one :business/, serializer)
    end
  end

  def test_generates_a_namespaced_serializer
    run_generator ['admin/account']
    assert_file 'app/serializers/admin/account_serializer.rb', /class Admin::AccountSerializer < ActiveModel::Serializer/
  end

  def test_uses_application_serializer_if_one_exists
    Object.const_set(:ApplicationSerializer, Class.new)
    run_generator
    assert_file 'app/serializers/account_serializer.rb', /class AccountSerializer < ApplicationSerializer/
  ensure
    Object.send :remove_const, :ApplicationSerializer
  end

  def test_uses_given_parent
    Object.const_set(:ApplicationSerializer, Class.new)
    run_generator ['Account', '--parent=MySerializer']
    assert_file 'app/serializers/account_serializer.rb', /class AccountSerializer < MySerializer/
  ensure
    Object.send :remove_const, :ApplicationSerializer
  end
end
