require 'test_helper'

module ActiveModel
  class Serializer
    class Settings
      class Test < ActiveModel::TestCase
        def test_settings_const_is_an_instance_of_settings
          assert_kind_of Settings, SETTINGS
        end

        def test_settings_instance
          settings = Settings.new
          settings[:setting1] = 'value1'

          assert_equal 'value1', settings[:setting1]
        end

        def test_each_settings
          settings = Settings.new
          settings['setting1'] = 'value1'
          settings['setting2'] = 'value2'

          actual = {}

          settings.each do |k, v|
            actual[k] = v
          end

          assert_equal({ 'setting1' => 'value1', 'setting2' => 'value2' }, actual)

        end
      end

      class SetupTest < ActiveModel::TestCase
        def test_setup
          ActiveModel::Serializer.setup do |settings|
            settings[:a] = 'v1'
            settings[:b] = 'v2'
          end

          assert_equal 'v1', SETTINGS[:a]
          assert_equal 'v2', SETTINGS[:b]
        ensure
          SETTINGS.clear
        end

        def test_setup_config_accessors
          ActiveModel::Serializer.setup do |config|
            config.foo = 'v1'
            config.bar = 'v2'
          end

          assert_equal 'v1', SETTINGS.foo
          assert_equal 'v2', SETTINGS.bar
        ensure
          SETTINGS.clear
        end

        def test_setup_acessor_when_nil
          assert_nil SETTINGS.foo
          SETTINGS.foo = 1
          assert 1, SETTINGS.foo
          assert_nil SETTINGS.bar
        end
      end
    end
  end
end
