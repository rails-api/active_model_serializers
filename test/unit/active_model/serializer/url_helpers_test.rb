require 'test_helper'

module ActiveModel
  class Serializer
    class UrlHelpersTest < Minitest::Test
      include Rails.application.routes.url_helpers

      def setup
        Object.const_set 'UserController', Class.new(ActionController::Base) do
          def show
            render text: 'profile'
          end
        end

        Rails.application.routes.draw do
          get '/profile/:id', as: :profile, controller: :user, action: :show
        end
      end

      def test_url_helpers_are_available
        serializer = Class.new(ActiveModel::Serializer) do
          attributes :url

          def url
            profile_url(id: object.object_id)
          end
        end
        profile = Profile.new

        assert_equal({ url: profile_url(id: profile.object_id) },
                     serializer.new(profile).as_json)
      end
    end
  end
end
