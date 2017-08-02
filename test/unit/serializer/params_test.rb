# frozen_string_literal: true
require "test_helper"

module AMS
  class Serializer
    class ParamsTest < Test
      class ParentModelSerializer < Serializer
        relation :child_models, type: :comments, to: :many, ids: "object.child_models.map(&:id)"
        relation :child_model, type: :comments, to: :one, id: "object.child_model.id"
        paginated
        query_params(:start_at, :end_at, filter: [:user_id])
      end

      def setup
        super
        @serializer_class = ParentModelSerializer
        @field_params = [:child_models, :child_model]
        @page_params = [:number, :size]
        @query_params = [:start_at, :end_at, filter: [:user_id]]
      end

      def test_show_params
        expected_params = [{ fields: @field_params }]
        assert_equal expected_params, @serializer_class.show_params
      end

      def test_index_params
        expected_params = [{ fields: @field_params }, { page: @page_params }, *@query_params]
        assert_equal expected_params, @serializer_class.index_params
      end
    end
  end
end
