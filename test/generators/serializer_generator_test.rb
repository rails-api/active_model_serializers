require 'test_helper'
require 'generators/rails/resource_override'
require 'generators/rails/serializer_generator'

class SerializerGeneratorTest < Rails::Generators::TestCase
  destination File.expand_path('../../../tmp/generators', __FILE__)
  setup :prepare_destination

  tests Rails::Generators::SerializerGenerator
  arguments %w(account name:string description:text business:references)

  test 'generates_a_serializer' do
    run_generator
    assert_file 'app/serializers/account_serializer.rb', /class AccountSerializer < ActiveModel::Serializer/
  end

  test 'generates_a_namespaced_serializer' do
    run_generator ['admin/account']
    assert_file 'app/serializers/admin/account_serializer.rb', /class Admin::AccountSerializer < ActiveModel::Serializer/
  end

  test 'uses_application_serializer_if_one_exists' do
    begin
      Object.const_set(:ApplicationSerializer, Class.new)
      run_generator
      assert_file 'app/serializers/account_serializer.rb', /class AccountSerializer < ApplicationSerializer/
    ensure
      Object.send :remove_const, :ApplicationSerializer
    end
  end

  test 'uses_given_parent' do
    begin
      Object.const_set(:ApplicationSerializer, Class.new)
      run_generator ['Account', '--parent=MySerializer']
      assert_file 'app/serializers/account_serializer.rb', /class AccountSerializer < MySerializer/
    ensure
      Object.send :remove_const, :ApplicationSerializer
    end
  end

  test 'generates_attributes_and_associations' do
    run_generator
    assert_file 'app/serializers/account_serializer.rb' do |serializer|
      assert_match(/^  attributes :id, :name, :description$/, serializer)
      assert_match(/^  has_one :business$/, serializer)
      assert_match(/^end\n*\z/, serializer)
    end
  end

  test 'with_no_attributes_does_not_add_extra_space' do
    run_generator ['account']
    assert_file 'app/serializers/account_serializer.rb' do |content|
      if RUBY_PLATFORM =~ /mingw/
        assert_no_match(/\r\n\r\nend/, content)
      else
        assert_no_match(/\n\nend/, content)
      end
    end
  end
end
