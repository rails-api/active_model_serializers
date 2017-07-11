# frozen_string_literal: true
require "test_helper"

module AMS
  class Serializer
    class RelationshipsTest < Test
      class ParentModelSerializer < Serializer
        # TODO: test to: :many without :ids option
        # TODO: test to: :one without :id option
        # TODO: test to: :unknown_option raises ArgumentError
        relation :child_models, type: :comments, to: :many, ids: "object.child_models.map(&:id)"
        relation :child_model, type: :comments, to: :one, id: "object.child_model.id"
      end

      def setup
        super
        @object = ParentModel.new(
          child_models: [ ChildModel.new(id: 2, name: "comments") ],
          child_model: ChildModel.new(id: 1, name: "comment")
        )
        @serializer_class = ParentModelSerializer
        @serializer_instance = @serializer_class.new(@object)
      end

      def test_model_instance_relations
        expected_relations = {
          child_models: {
            data: [{ type: "comments", id: "2" }]
          },
          child_model: {
            data: { type: "comments", id: "1" }
          }
        }
        assert_equal expected_relations, @serializer_instance.relations
      end

      def test_model_instance_relationship_data
        expected = {
          type: :bananas, id: "5"
        }
        assert_equal expected, @serializer_instance.relationship_data(5, :bananas)
      end

      def test_model_instance_relationship_to_one
        expected = {
          data: { id: @object.child_model.id.to_s, type: "comments" }
        }
        assert_equal expected, @serializer_instance.child_model
      end

      def test_model_instance_relationship_to_one_id
        expected = @object.child_model.id
        assert_equal expected, @serializer_instance.related_child_model_id
      end

      def test_model_instance_relationship_to_many
        expected = {
          data: [{ id: @object.child_models.first.id.to_s, type: "comments" }]
        }
        assert_equal expected, @serializer_instance.child_models
      end

      def test_model_instance_relationship_to_many_ids
        expected = @object.child_models.map(&:id)
        assert_equal expected, @serializer_instance.related_child_models_ids
      end
    end
  end
end
