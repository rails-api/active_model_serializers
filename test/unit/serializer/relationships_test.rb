# frozen_string_literal: true
require "test_helper"

module AMS
  class Serializer
    class RelationshipsTest < Test
      class ParentModelSerializer < Serializer
        relation :child_models, type: :comments, to: :many, ids: "object.child_models.map(&:id)"
      end

      def setup
        super
        @relation = ChildModel.new(id: 2, name: "comment")
        @object = ParentModel.new(
          child_models: [@relation]
        )
        @serializer_class = ParentModelSerializer
        @serializer_instance = @serializer_class.new(@object)
      end

      def test_model_instance_relations
        expected_relations = {
          child_models: [{
            data: { type: "comments", id: 2 }
          }]
        }
        assert_equal expected_relations, @serializer_instance.relations
      end

      def test_model_instance_relationship_object
        expected = {
          data: { type: :bananas, id: 5 }
        }
        assert_equal expected, @serializer_instance.relationship_object(5, :bananas)
      end
    end
  end
end
