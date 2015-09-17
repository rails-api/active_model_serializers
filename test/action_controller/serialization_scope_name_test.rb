require 'test_helper'
require 'pathname'

class DefaultScopeNameTest < ActionController::TestCase
  class UserSerialization < ActiveModel::Serializer
    attributes :admin?
    ActiveModelSerializers.silence_warnings do
      def admin?
        current_user.admin
      end
    end
  end

  class UserTestController < ActionController::Base
    protect_from_forgery

    before_filter { request.format = :json }

    def current_user
      User.new(id: 1, name: 'Pete', admin: false)
    end

    def render_new_user
      render json: User.new(id: 1, name: 'Pete', admin: false), serializer: UserSerialization, adapter: :json_api
    end
  end

  tests UserTestController

  def test_default_scope_name
    get :render_new_user
    assert_equal '{"data":{"id":"1","type":"users","attributes":{"admin?":false}}}', @response.body
  end
end

class SerializationScopeNameTest < ActionController::TestCase
  class AdminUserSerialization < ActiveModel::Serializer
    attributes :admin?
    ActiveModelSerializers.silence_warnings do
      def admin?
        current_admin.admin
      end
    end
  end

  class AdminUserTestController < ActionController::Base
    protect_from_forgery

    serialization_scope :current_admin
    before_filter { request.format = :json }

    def current_admin
      User.new(id: 2, name: 'Bob', admin: true)
    end

    def render_new_user
      render json: User.new(id: 1, name: 'Pete', admin: false), serializer: AdminUserSerialization, adapter: :json_api
    end
  end

  tests AdminUserTestController

  def test_override_scope_name_with_controller
    get :render_new_user
    assert_equal '{"data":{"id":"1","type":"users","attributes":{"admin?":true}}}', @response.body
  end
end
