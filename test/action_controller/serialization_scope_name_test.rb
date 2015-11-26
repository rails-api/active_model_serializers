require 'test_helper'
require 'pathname'

class DefaultScopeNameTest < ActionController::TestCase
  class UserSerializer < ActiveModel::Serializer
    def admin?
      current_user.admin
    end
    attributes :admin?
  end

  class UserTestController < ActionController::Base
    protect_from_forgery

    before_action { request.format = :json }

    def current_user
      User.new(id: 1, name: 'Pete', admin: false)
    end

    def render_new_user
      render json: User.new(id: 1, name: 'Pete', admin: false), serializer: UserSerializer, adapter: :json_api
    end
  end

  tests UserTestController

  def test_default_scope_name
    get :render_new_user
    assert_equal '{"data":{"id":"1","type":"users","attributes":{"admin?":false}}}', @response.body
  end
end

class SerializationScopeNameTest < ActionController::TestCase
  class AdminUserSerializer < ActiveModel::Serializer
    def admin?
      current_admin.admin
    end
    attributes :admin?
  end

  class AdminUserTestController < ActionController::Base
    protect_from_forgery

    serialization_scope :current_admin
    before_action { request.format = :json }

    def current_admin
      User.new(id: 2, name: 'Bob', admin: true)
    end

    def render_new_user
      render json: User.new(id: 1, name: 'Pete', admin: false), serializer: AdminUserSerializer, adapter: :json_api
    end
  end

  tests AdminUserTestController

  def test_override_scope_name_with_controller
    get :render_new_user
    assert_equal '{"data":{"id":"1","type":"users","attributes":{"admin?":true}}}', @response.body
  end
end
