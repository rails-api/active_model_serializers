require 'test_helper'

module ActiveModel
  class Serializer
    class Configuration
      class Test < Minitest::Test
        class ParentConfiguration < Configuration
          options :root, :embed_in_root, :embed

          def default_options
            { embed: :objects }
          end
        end

        class ChildConfiguration < ParentConfiguration
          options :scope
        end

        def setup
          @parent = ParentConfiguration.new nil, root: 'root', embed_in_root: true
          @child  = ChildConfiguration.new @parent, root: 'other'
        end

        def test_configuration_has_root_option
          assert_equal 'root', @parent.root
        end

        def test_parent_has_default_embed_option
          assert_equal :objects, @parent.embed
        end

        def test_child_returns_own_root_option
          assert_equal 'other', @child.root
        end

        def test_child_returns_parent_embed_in_root_option
          assert_equal true, @child.embed_in_root
        end

        def test_child_returns_nil_for_non_existing_parent_option
          assert_equal nil, @child.scope
        end
      end
    end

    class SerializerConfiguration
      class Test < Minitest::Test
        def setup
          @configuration = SerializerConfiguration.new nil, root: 'root'
        end

        def test_configuration_inherits_from_base_class
          assert_kind_of Configuration, @configuration
        end

        def test_configuration_has_root_option
          assert_equal 'root', @configuration.root
        end

        def test_configuration_sets_root_option
          @configuration.root = 'other'
          assert_equal 'other', @configuration.root
        end

        def test_configuration_has_default_embed_option
          assert_equal :objects, @configuration.embed
        end
      end
    end

    class GlobalConfiguration
      class Test < Minitest::Test
        def setup
          @configuration = GlobalConfiguration.instance
        end

        def test_configuration_inherits_from_base_class
          assert_kind_of Configuration, @configuration
        end

        def test_returns_singleton_configuration
          other = GlobalConfiguration.instance
          assert @configuration == other, "instances don't match"
        end
      end
    end

    class ClassConfiguration
      class Test < Minitest::Test
        def setup
          @configuration = ClassConfiguration.new nil, root: 'root'
        end

        def test_configuration_inherits_from_base_class
          assert_kind_of Configuration, @configuration
        end

        def test_configuration_has_root_option
          assert_equal 'root', @configuration.root
        end

        def test_configuration_sets_root_option
          @configuration.root = 'other'
          assert_equal 'other', @configuration.root
        end

        def test_configuration_has_default_embed_option
          assert_equal :objects, @configuration.embed
        end
      end
    end

    class InstanceConfiguration
      class Test < Minitest::Test
        def setup
          @configuration = InstanceConfiguration.new nil, scope: :current_user
        end

        def test_configuration_inherits_from_base_class
          assert_kind_of ClassConfiguration, @configuration
        end

        def test_configuration_has_root_option
          assert_equal :current_user, @configuration.scope
        end
      end
    end

    class ArrayConfiguration
      class Test < Minitest::Test
        def setup
          @configuration = ArrayConfiguration.new nil, resource_name: 'posts'
        end

        def test_configuration_inherits_from_base_class
          assert_kind_of Configuration, @configuration
        end

        def test_configuration_has_resource_name_option
          assert_equal 'posts', @configuration.resource_name
        end
      end
    end
  end
end
