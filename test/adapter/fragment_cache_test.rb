require 'test_helper'
module ActiveModel
  class Serializer
    class Adapter
      class FragmentCacheTest < Minitest::Test

        def test_fragment_fetch_with_virtual_attributes
          author          = Author.new(name: 'Joao M. D. Moura')
          role            = Role.new(name: 'Great Author', description:nil)
          role.author     = [author]
          role_serializer = RoleSerializer.new(role)
          role_hash       = FragmentCache.new(RoleSerializer.adapter.new(role_serializer), role_serializer, {}, nil)

          expected_result = {
            id: role.id,
            description: role.description,
            slug: "#{role.name}-#{role.id}",
            name: role.name
          }
          assert_equal(expected_result, role_hash.fetch)
        end

        def test_fragment_fetch_with_scoped_model
          role            = Test::NestedRole.new(name: 'Great Author', description:nil)
          role_serializer = RoleSerializer.new(role)
          role_hash       = FragmentCache.new(RoleSerializer.adapter.new(role_serializer), role_serializer, {}, nil)

          expected_result = {
            id: role.id,
            description: role.description,
            slug: "#{role.name}-#{role.id}",
            name: role.name
          }
          assert_equal(expected_result, role_hash.fetch)
        end

        def test_format_for_scoped_names
          name = 'Test::nestedRole'

          assert_equal('Test::NestedRole', FragmentCache.new(nil, nil, nil, nil).format(name))
        end

        def test_format_for_scoped_names_camelized
          name = 'Test::NestedRole'

          assert_equal('Test::NestedRole', FragmentCache.new(nil, nil, nil, nil).format(name))
        end

        def test_format_for_simple_names
          name = 'NestedRole'

          assert_equal('NestedRole', FragmentCache.new(nil, nil, nil, nil).format(name))
        end

        def test_get_scope_for_simple_name
          name = 'Role'

          assert_equal(Object, FragmentCache.new(nil, nil, nil, nil).get_scope(name))
        end

        def test_get_scope_for_nested_name
          name = 'Test::NestedRole'

          assert_equal(Test, FragmentCache.new(nil, nil, nil, nil).get_scope(name))
        end

      end
    end
  end
end

