require "test_helper"

class NoSerializationScopeTest < ActionController::TestCase
  class ScopeSerializer
    def initialize(object, options)
      @object, @options = object, options
    end

    def as_json(*)
      { :scope => @options[:scope].as_json }
    end
  end

  class ScopeSerializable
    def active_model_serializer
      ScopeSerializer
    end
  end

  class NoSerializationScopeController < ActionController::Base
    serialization_scope nil

    def index
      render :json => ScopeSerializable.new
    end
  end

  tests NoSerializationScopeController

  def test_disabled_serialization_scope
    get :index, :format => :json
    assert_equal '{"scope":null}', @response.body
  end
end
