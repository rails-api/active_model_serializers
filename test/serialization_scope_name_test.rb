require 'test_helper'
require 'pathname'

class DefaultScopeNameTest < ActionController::TestCase
  TestUser = Struct.new(:name, :admin)

  class UserSerializer < ActiveModel::Serializer
    attributes :admin?
    def admin?
      current_user.admin
    end
  end

  class UserTestController < ActionController::Base
    protect_from_forgery

    before_filter { request.format = :json }

    def current_user
      TestUser.new('Pete', false)
    end

    def render_new_user
      render :json => TestUser.new('pete', false), :serializer => UserSerializer
    end
  end

 tests UserTestController

  def test_default_scope_name
    get :render_new_user
    assert_equal '{"user":{"admin":false}}', @response.body
  end
end

class SerializationScopeNameTest < ActionController::TestCase
  TestUser = Struct.new(:name, :admin)

  class AdminUserSerializer < ActiveModel::Serializer
    attributes :admin?
    def admin?
      current_admin.admin
    end
  end

  class AdminUserTestController < ActionController::Base
    protect_from_forgery

    serialization_scope :current_admin
    before_filter { request.format = :json }

    def current_admin
      TestUser.new('Bob', true)
    end

    def render_new_user
      render :json => TestUser.new('pete', false), :serializer => AdminUserSerializer
    end
  end

  tests AdminUserTestController

  def test_override_scope_name_with_controller
    get :render_new_user
    assert_equal '{"admin_user":{"admin":true}}', @response.body
  end
end
