# frozen_string_literal: true
require "test_helper"

module AMS
  class Serializer
    class AsJsonTest < Test
      class ParentModelSerializer < Serializer
        id_field :id
        type :profiles
        attribute :name
        attribute :description, key: :summary
        relation :child_models, type: :comments, to: :many, ids: "object.child_models.map(&:id)"
      end

      def setup
        super
        @relation = ChildModel.new(id: 2, name: "comment")
        @object = ParentModel.new(
          id: 1,
          name: "name",
          description: "description",
          child_models: [@relation]
        )
        @serializer_class = ParentModelSerializer
        @serializer_instance = @serializer_class.new(@object)
      end

      def test_model_instance_as_json
        expected = {
          id: "1", type: :profiles,
          attributes: { name: "name", summary: "description" },
          relationships:
          { child_models: { data: [{ id: "2", type: "comments" }] } }
        }
        assert_equal expected, @serializer_instance.as_json
      end

      def test_model_instance_to_json
        expected = {
          id: "1", type: :profiles,
          attributes: { name: "name", summary: "description" },
          relationships:
          { child_models: { data: [{ id: "2", type: "comments" }] } }
        }.to_json
        assert_equal expected, @serializer_instance.to_json
      end

      def test_model_instance_dump
        expected = {
          id: "1", type: :profiles
        }.to_json
        assert_equal expected, @serializer_instance.dump(id: "1", type: :profiles)
      end
    end
  end
end
