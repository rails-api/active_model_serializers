require 'test_helper'
require 'pathname'

class RenderJsonTest < ActionController::TestCase
  class JsonRenderable
    def as_json(options={})
      hash = { :a => :b, :c => :d, :e => :f }
      hash.except!(*options[:except]) if options[:except]
      hash
    end

    def to_json(options = {})
      super :except => [:c, :e]
    end
  end

  class JsonSerializer
    def initialize(object, options={})
      @object, @options = object, options
    end

    def as_json(*)
      hash = { :object => serializable_hash, :scope => @options[:scope].as_json }
      hash.merge!(:options => true) if @options[:options]
      hash.merge!(:check_defaults => true) if @options[:check_defaults]
      hash
    end

    def serializable_hash
      @object.as_json
    end
  end

  class JsonSerializable
    def initialize(skip=false)
      @skip = skip
    end

    def active_model_serializer
      JsonSerializer unless @skip
    end

    def as_json(*)
      { :serializable_object => true }
    end
  end

  class CustomSerializer
    def initialize(*)
    end

    def as_json(*)
      { :hello => true }
    end
  end

  class AnotherCustomSerializer
    def initialize(*)
    end

    def as_json(*)
      { :rails => 'rocks' }
    end
  end

  class DummyCustomSerializer < ActiveModel::Serializer
    attributes :id
  end

  class HypermediaSerializable
    def active_model_serializer
      HypermediaSerializer
    end
  end

  class HypermediaSerializer < ActiveModel::Serializer
    def as_json(*)
      { :link => hypermedia_url }
    end
  end

  class CustomArraySerializer < ActiveModel::ArraySerializer
    self.root = "items"
  end

  class TestController < ActionController::Base
    protect_from_forgery

    serialization_scope :current_user
    attr_reader :current_user

    def self.controller_path
      'test'
    end

    def render_json_nil
      render :json => nil
    end

    def render_json_render_to_string
      render :text => render_to_string(:json => '[]')
    end

    def render_json_hello_world
      render :json => ActiveSupport::JSON.encode(:hello => 'world')
    end

    def render_json_hello_world_with_status
      render :json => ActiveSupport::JSON.encode(:hello => 'world'), :status => 401
    end

    def render_json_hello_world_with_callback
      render :json => ActiveSupport::JSON.encode(:hello => 'world'), :callback => 'alert'
    end

    def render_json_with_custom_content_type
      render :json => ActiveSupport::JSON.encode(:hello => 'world'), :content_type => 'text/javascript'
    end

    def render_symbol_json
      render :json => ActiveSupport::JSON.encode(:hello => 'world')
    end

    def render_json_nil_with_custom_serializer
      render :json => nil, :serializer => DummyCustomSerializer
    end


    def render_json_with_extra_options
      render :json => JsonRenderable.new, :except => [:c, :e]
    end

    def render_json_without_options
      render :json => JsonRenderable.new
    end

    def render_json_with_serializer
      @current_user = Struct.new(:as_json).new(:current_user => true)
      render :json => JsonSerializable.new
    end

    def render_json_with_serializer_and_implicit_root
      @current_user = Struct.new(:as_json).new(:current_user => true)
      render :json => [JsonSerializable.new]
    end

    def render_json_with_serializer_and_options
      @current_user = Struct.new(:as_json).new(:current_user => true)
      render :json => JsonSerializable.new, :options => true
    end

    def render_json_with_serializer_and_scope_option
      @current_user = Struct.new(:as_json).new(:current_user => true)
      scope = Struct.new(:as_json).new(:current_user => false)
      render :json => JsonSerializable.new, :scope => scope
    end

    def render_json_with_serializer_api_but_without_serializer
      @current_user = Struct.new(:as_json).new(:current_user => true)
      render :json => JsonSerializable.new(true)
    end

    # To specify a custom serializer for an object, use :serializer.
    def render_json_with_custom_serializer
      render :json => Object.new, :serializer => CustomSerializer
    end

    # To specify a custom serializer for each item in the Array, use :each_serializer.
    def render_json_array_with_custom_serializer
      render :json => [Object.new], :each_serializer => CustomSerializer
    end

    def render_json_array_with_wrong_option
      render :json => [Object.new], :serializer => CustomSerializer
    end

    def render_json_with_links
      render :json => HypermediaSerializable.new
    end

    def render_json_array_with_no_root
      render :json => [], :root => false
    end

    def render_json_empty_array
      render :json => []
    end

    def render_json_array_with_custom_array_serializer
      render :json => [], :serializer => CustomArraySerializer
    end


  private
    def default_serializer_options
      defaults = {}
      defaults.merge!(:check_defaults => true) if params[:check_defaults]
      defaults.merge!(:root => :awesome) if params[:check_default_root]
      defaults.merge!(:scope => :current_admin) if params[:check_default_scope]
      defaults.merge!(:serializer => AnotherCustomSerializer) if params[:check_default_serializer]
      defaults.merge!(:each_serializer => AnotherCustomSerializer) if params[:check_default_each_serializer]
      defaults
    end
  end

  tests TestController

  def setup
    # enable a logger so that (e.g.) the benchmarking stuff runs, so we can get
    # a more accurate simulation of what happens in "real life".
    super
    @controller.logger = Logger.new(nil)

    @request.host = "www.nextangle.com"
  end

  def test_render_json_nil
    get :render_json_nil
    assert_equal 'null', @response.body
    assert_equal 'application/json', @response.content_type
  end

  def test_render_json_render_to_string
    get :render_json_render_to_string
    assert_equal '[]', @response.body
  end

  def test_render_json_nil_with_custom_serializer
    get :render_json_nil_with_custom_serializer
    assert_equal "{\"dummy_custom\":null}", @response.body
  end

  def test_render_json
    get :render_json_hello_world
    assert_equal '{"hello":"world"}', @response.body
    assert_equal 'application/json', @response.content_type
  end

  def test_render_json_with_status
    get :render_json_hello_world_with_status
    assert_equal '{"hello":"world"}', @response.body
    assert_equal 401, @response.status
  end

  def test_render_json_with_callback
    get :render_json_hello_world_with_callback
    assert_equal 'alert({"hello":"world"})', @response.body
    # For JSONP, Rails 3 uses application/json, but Rails 4 uses text/javascript
    assert_match %r(application/json|text/javascript), @response.content_type.to_s
  end

  def test_render_json_with_custom_content_type
    get :render_json_with_custom_content_type
    assert_equal '{"hello":"world"}', @response.body
    assert_equal 'text/javascript', @response.content_type
  end

  def test_render_symbol_json
    get :render_symbol_json
    assert_equal '{"hello":"world"}', @response.body
    assert_equal 'application/json', @response.content_type
  end

  def test_render_json_forwards_extra_options
    get :render_json_with_extra_options
    assert_equal '{"a":"b"}', @response.body
    assert_equal 'application/json', @response.content_type
  end

  def test_render_json_calls_to_json_from_object
    get :render_json_without_options
    assert_equal '{"a":"b"}', @response.body
  end

  def test_render_json_with_serializer
    get :render_json_with_serializer
    assert_match '"scope":{"current_user":true}', @response.body
    assert_match '"object":{"serializable_object":true}', @response.body
  end

  def test_render_json_with_serializer_checking_defaults
    get :render_json_with_serializer, :check_defaults => true
    assert_match '"scope":{"current_user":true}', @response.body
    assert_match '"object":{"serializable_object":true}', @response.body
    assert_match '"check_defaults":true', @response.body
  end

  def test_render_json_with_serializer_checking_default_serailizer
    get :render_json_with_serializer, :check_default_serializer => true
    assert_match '{"rails":"rocks"}', @response.body
  end

  def test_render_json_with_serializer_checking_default_scope
    get :render_json_with_serializer, :check_default_scope => true
    assert_match '"scope":"current_admin"', @response.body
  end

  def test_render_json_with_serializer_and_implicit_root
    get :render_json_with_serializer_and_implicit_root
    assert_match '"test":[{"serializable_object":true}]', @response.body
  end

  def test_render_json_with_serializer_and_implicit_root_checking_default_each_serailizer
    get :render_json_with_serializer_and_implicit_root, :check_default_each_serializer => true
    assert_match '"test":[{"rails":"rocks"}]', @response.body
  end

  def test_render_json_with_serializer_and_options
    get :render_json_with_serializer_and_options
    assert_match '"scope":{"current_user":true}', @response.body
    assert_match '"object":{"serializable_object":true}', @response.body
    assert_match '"options":true', @response.body
  end

  def test_render_json_with_serializer_and_scope_option
    get :render_json_with_serializer_and_scope_option
    assert_match '"scope":{"current_user":false}', @response.body
  end

  def test_render_json_with_serializer_and_scope_option_checking_default_scope
    get :render_json_with_serializer_and_scope_option, :check_default_scope => true
    assert_match '"scope":{"current_user":false}', @response.body
  end

  def test_render_json_with_serializer_api_but_without_serializer
    get :render_json_with_serializer_api_but_without_serializer
    assert_match '{"serializable_object":true}', @response.body
  end

  def test_render_json_with_custom_serializer
    get :render_json_with_custom_serializer
    assert_match '{"hello":true}', @response.body
  end

  def test_render_json_with_custom_serializer_checking_default_serailizer
    get :render_json_with_custom_serializer, :check_default_serializer => true
    assert_match '{"hello":true}', @response.body
  end

  def test_render_json_array_with_custom_serializer
    get :render_json_array_with_custom_serializer
    assert_match '{"test":[{"hello":true}]}', @response.body
  end

  def test_render_json_array_with_wrong_option
    assert_raise ArgumentError do
      get :render_json_array_with_wrong_option
    end
  end

  def test_render_json_array_with_custom_serializer_checking_default_each_serailizer
    get :render_json_array_with_custom_serializer, :check_default_each_serializer => true
    assert_match '{"test":[{"hello":true}]}', @response.body
  end

  def test_render_json_with_links
    get :render_json_with_links
    assert_match '{"link":"http://www.nextangle.com/hypermedia"}', @response.body
  end

  def test_render_json_array_with_no_root
    get :render_json_array_with_no_root
    assert_equal '[]', @response.body
  end

  def test_render_json_array_with_no_root_checking_default_root
    get :render_json_array_with_no_root, :check_default_root => true
    assert_equal '[]', @response.body
  end

  def test_render_json_empty_array
    get :render_json_empty_array
    assert_equal '{"test":[]}', @response.body
  end

  def test_render_json_empty_array_checking_default_root
    get :render_json_empty_array, :check_default_root => true
    assert_equal '{"awesome":[]}', @response.body
  end

  def test_render_json_empty_array_with_array_serializer_root_false
    ActiveModel::ArraySerializer.root = false
    get :render_json_empty_array
    assert_equal '[]', @response.body
  ensure # teardown
    ActiveModel::ArraySerializer.root = nil
  end

  def test_render_json_array_with_custom_array_serializer
    get :render_json_array_with_custom_array_serializer
    assert_equal '{"items":[]}', @response.body
  end

end
