require 'newbase/test_helper'
require 'newbase/active_model_serializers'

module ActionController
  module Serialization
    class ImplicitSerializerTest < ActionController::TestCase
      class Model
        include ActiveModel::SerializerSupport

        def initialize(hash={})
          @attributes = hash
        end

        def read_attribute_for_serialization(name)
          @attributes[name]
        end
      end

      class ModelSerializer < ActiveModel::Serializer
        attributes :attr1, :attr2
      end

      class MyController < ActionController::Base
        def render_using_implicit_serializer
          render :json => Model.new(attr1: 'value1', attr2: 'value2', attr3: 'value3')
        end
      end

      tests MyController

      def test_render_using_implicit_serializer
        get :render_using_implicit_serializer
        assert_equal 'application/json', @response.content_type
        assert_equal '{"attr1":"value1","attr2":"value2"}', @response.body
      end
    end

    class ImplicitSerializerScopeTest < ActionController::TestCase
      class Model
        include ActiveModel::SerializerSupport

        def initialize(hash={})
          @attributes = hash
        end

        def read_attribute_for_serialization(name)
          @attributes[name]
        end
      end

      class ModelSerializer < ActiveModel::Serializer
        attributes :attr1, :attr2

        def attr2
          object.read_attribute_for_serialization(:attr2) + '-' + scope
        end
      end

      class MyController < ActionController::Base
        def render_using_implicit_serializer_and_scope
          render :json => Model.new(attr1: 'value1', attr2: 'value2', attr3: 'value3')
        end

        protected

        def current_user
          'current_user'
        end
      end

      tests MyController

      def test_render_using_implicit_serializer_and_scope
        get :render_using_implicit_serializer_and_scope
        assert_equal 'application/json', @response.content_type
        assert_equal '{"attr1":"value1","attr2":"value2-current_user"}', @response.body
      end
    end

    class ExplicitSerializerScopeTest < ActionController::TestCase
      class Model
        include ActiveModel::SerializerSupport

        def initialize(hash={})
          @attributes = hash
        end

        def read_attribute_for_serialization(name)
          @attributes[name]
        end
      end

      class ModelSerializer < ActiveModel::Serializer
        attributes :attr1, :attr2

        def attr2
          object.read_attribute_for_serialization(:attr2) + '-' + scope
        end
      end

      class MyController < ActionController::Base
        def render_using_implicit_serializer_and_explicit_scope
          render json: Model.new(attr1: 'value1', attr2: 'value2', attr3: 'value3'), scope: current_admin
        end

        private

        def current_user
          'current_user'
        end

        def current_admin
          'current_admin'
        end
      end

      tests MyController

      def test_render_using_implicit_serializer_and_explicit_scope
        get :render_using_implicit_serializer_and_explicit_scope
        assert_equal 'application/json', @response.content_type
        assert_equal '{"attr1":"value1","attr2":"value2-current_admin"}', @response.body
      end
    end

    class OverridingSerializationScopeTest < ActionController::TestCase
      class Model
        include ActiveModel::SerializerSupport

        def initialize(hash={})
          @attributes = hash
        end

        def read_attribute_for_serialization(name)
          @attributes[name]
        end
      end

      class ModelSerializer < ActiveModel::Serializer
        attributes :attr1, :attr2

        def attr2
          object.read_attribute_for_serialization(:attr2) + '-' + scope
        end
      end

      class MyController < ActionController::Base
        def render_overriding_serialization_scope
          render json: Model.new(attr1: 'value1', attr2: 'value2', attr3: 'value3')
        end

        private

        def current_user
          'current_user'
        end

        def serialization_scope
          'current_admin'
        end
      end

      tests MyController

      def test_render_overriding_serialization_scope
        get :render_overriding_serialization_scope
        assert_equal 'application/json', @response.content_type
        assert_equal '{"attr1":"value1","attr2":"value2-current_admin"}', @response.body
      end
    end
  end
end
