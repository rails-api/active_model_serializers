require 'test_helper'
require 'rails'
require 'active_model/serializer/railtie'
require 'test_app'

class ScaffoldControllerGeneratorTest < Rails::Generators::TestCase
  destination File.expand_path('../../../tmp', __FILE__)
  setup :prepare_destination

  tests Rails::Generators::ScaffoldControllerGenerator
  arguments %w(account name:string description:text business:references)

  def test_generated_controller
    return true if Rails::VERSION::MAJOR < 4

    run_generator

    assert_file 'app/controllers/accounts_controller.rb' do |content|
      assert_instance_method :index, content do |m|
        assert_match /@accounts = Account\.all/, m
        assert_match /format.html/, m
        assert_match /format.json \{ render json: @accounts \}/, m
      end

      assert_instance_method :show, content do |m|
        assert_match /format.html/, m
        assert_match /format.json \{ render json: @account \}/, m
      end

      assert_instance_method :new, content do |m|
        assert_match /@account = Account\.new/, m
      end

      assert_instance_method :edit, content do |m|
        assert m.blank?
      end

      assert_instance_method :create, content do |m|
        assert_match /@account = Account\.new\(account_params\)/, m
        assert_match /@account\.save/, m
        assert_match /format\.html \{ redirect_to @account, notice: 'Account was successfully created\.' \}/, m
        assert_match /format\.json \{ render json: @account, status: :created \}/, m
        assert_match /format\.html \{ render action: 'new' \}/, m
        assert_match /format\.json \{ render json: @account\.errors, status: :unprocessable_entity \}/, m
      end

      assert_instance_method :update, content do |m|
        assert_match /format\.html \{ redirect_to @account, notice: 'Account was successfully updated\.' \}/, m
        assert_match /format\.json \{ head :no_content \}/, m
        assert_match /format\.html \{ render action: 'edit' \}/, m
        assert_match /format\.json \{ render json: @account.errors, status: :unprocessable_entity \}/, m
      end

      assert_instance_method :destroy, content do |m|
        assert_match /@account\.destroy/, m
        assert_match /format\.html { redirect_to accounts_url \}/, m
        assert_match /format\.json \{ head :no_content \}/, m
      end

      assert_match(/def account_params/, content)
      assert_match(/params\.require\(:account\)\.permit\(:name, :description, :business_id\)/, content)
    end
  end
end
