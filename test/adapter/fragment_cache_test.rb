require 'test_helper'
module ActiveModel
  class Serializer
    class Adapter
      class FragmentCacheTest < Minitest::Test
        def setup
          @author          = Author.new(name: 'Joao M. D. Moura')
          @role            = Role.new(name: 'Great Author', description:nil)
          @role.author     = [@author]
          @role_serializer = RoleSerializer.new(@role)
          @role_hash       = FragmentCache.new(RoleSerializer.adapter.new(@role_serializer), @role_serializer, {}, nil)
        end

        def test_fragment_fetch_with_virtual_attributes
          expected_result = {
            id: @role.id,
            description: @role.description,
            slug: "#{@role.name}-#{@role.id}",
            name: @role.name
          }
          assert_equal(@role_hash.fetch, expected_result)
        end
      end
    end
  end
end

