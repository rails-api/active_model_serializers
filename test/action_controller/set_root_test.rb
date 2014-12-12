require 'test_helper'

module ActionController
  module Serialization
    class SetRootTest < ActionController::TestCase

      class SetRootController < ActionController::Base
        def index
          render json: [SetRootTester.new(id: 32)]
        end

        def show
          render json: SetRootTester.new(id: 33)
        end
      end

      tests SetRootController

      def test_no_root_index
        get :index
        assert_equal '{"junks":[{"junk":{"id":32}}]}', @response.body
      end

      def test_no_root_show
        get :show
        assert_equal '{"junk":{"id":33}}', @response.body
      end
    end
  end
end
