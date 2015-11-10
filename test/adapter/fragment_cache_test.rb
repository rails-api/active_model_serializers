require 'test_helper'
module ActiveModel
  class Serializer
    module Adapter
      class FragmentCacheTest < Minitest::Test
        def setup
          super
          @spam            = Spam::UnrelatedLink.new(id: 'spam-id-1')
          @author          = Author.new(name: 'Joao M. D. Moura')
          @role            = Role.new(name: 'Great Author', description: nil)
          @role.author     = [@author]
          @role_serializer = RoleSerializer.new(@role)
          @spam_serializer = Spam::UnrelatedLinkSerializer.new(@spam)
          @role_hash       = FragmentCache.new(RoleSerializer.adapter.new(@role_serializer), @role_serializer, {})
          @spam_hash       = FragmentCache.new(Spam::UnrelatedLinkSerializer.adapter.new(@spam_serializer), @spam_serializer, {})
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

        def test_fragment_fetch_with_namespaced_object
          expected_result = {
            id: @spam.id
          }
          assert_equal(@spam_hash.fetch, expected_result)
        end
      end
    end
  end
end

