require 'test_helper'

module ActiveModel
  class Serializer
    class Configuration
      class GlobalTest < Minitest::Test
        def test_returns_global_configuration
          assert_kind_of Configuration, Configuration.global
        end

        def test_global_configuration_returns_the_same_instance
          assert_equal Configuration.global.object_id, Configuration.global.object_id
        end

        def test_global_configuration_has_default_options_set
          assert Configuration.default_options.all? do |name, value|
            Configuration.global.send(name) == value
          end
        end
      end

      class OptionsTest < Minitest::Test
        def setup
          @configuration = Configuration.global.build(root: 'root', embed: :ids, embed_in_root: false)
        end

        def test_configuration_has_root_option
          assert_equal 'root', @configuration.root
        end

        def test_configuration_has_embed_option
          assert_equal :ids, @configuration.embed
        end

        def test_configuration_has_embed_in_root_option
          assert_equal false, @configuration.embed_in_root
        end
      end
    end
  end
end
