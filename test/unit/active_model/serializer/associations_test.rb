require 'test_helper'

module ActiveModel
  class Serializer
    class AssociationsTest < Minitest::Test
      def test_associations_inheritance
        inherited_serializer_klass = Class.new(PostSerializer) do
          has_many :users
        end
        another_inherited_serializer_klass = Class.new(PostSerializer)

        assert_equal([:comments, :users],
                     inherited_serializer_klass._associations.keys)
        assert_equal([:comments],
                     another_inherited_serializer_klass._associations.keys)
      end
      def test_multiple_nested_associations
        parent = SelfReferencingUserParent.new(name: "The Parent")
        child = SelfReferencingUser.new(name: "The child", parent: parent)
        self_referencing_user_serializer = SelfReferencingUserSerializer.new(child)
        result = self_referencing_user_serializer.as_json
        expected_result = {
          "self_referencing_user"=>{
            :name=>"The child",
            "type_id"=>child.type.object_id,
            "parent_id"=>child.parent.object_id

          },
          "types"=>[
            {
              :name=>"N1",
            },
            {
              :name=>"N2",
            }
          ],
          "parents"=>[
            {
              :name=>"N1",
              "type_id"=>child.parent.type.object_id,
              "parent_id"=>nil
            }
          ]
        }
        assert_equal(expected_result, result)
      end
    end
  end
end
