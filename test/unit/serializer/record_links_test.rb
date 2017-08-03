# frozen_string_literal: true
require "test_helper"

module AMS
  class Serializer
    class RecordLinksTest < Test
      class ActiveRecordSerializer < ::AMS::Serializer; end
      class ParentRecordSerializer < ActiveRecordSerializer
        id_field :id
        type :profiles
        attribute :name
        attribute :description, key: :summary
        relation :child_records, type: :comments, to: :many
        relation :child_record, type: :posts, to: :one
      end

      class ParentRecord < ParentModel
        def self.table_name
          "parent_records"
        end

        alias child_record child_model
      end
      class ChildRecord < ChildModel
      end

      def setup
        super
        @to_many_relation = [ChildRecord.new(id: 2, name: "to_many")]
        @to_one_relation = ChildRecord.new(id: 3, name: "to_one")
        @object = ParentRecord.new(
          id: 1,
          name: "name",
          description: "description",
          child_models: @to_many_relation,
          child_model: @to_one_relation
        )
        @serializer_class = ParentRecordSerializer
        link_builder = Object.new
        def link_builder.url_for(controller:, action:, params: {}, **options)
          query = params.map { |k, v| v.is_a?(Hash) ? v.map { |vk, vv| "#{k}[#{vk}]=#{vv}" }.join("&") : "#{k}=#{v}" }.join("&")
          optional =
            if options.key?(:id)
              "/#{options[:id]}"
            else
              ""
            end
          query = "?#{query}" unless query.empty?
          "https://example.com/#{controller}/#{action}#{optional}#{query}"
        end
        @serializer_instance = @serializer_class.new(@object,  link_builder: link_builder)
      end

      def test_record_instance_as_json
        expected = {
          id: "1", type: :profiles,
          attributes: { name: "name", summary: "description" },
          relationships: {
           child_records: { links: { related: "https://example.com/comments/index?filter[parent_record_id]=1" } } ,
           child_record: { data: { id: "3", type: "posts" }, links: { related: "https://example.com/posts/show/3" } },
},
          links: { self: "https://example.com/profiles/show/1" }
        }
        assert_equal expected, @serializer_instance.as_json
      end

      def test_record_instance_to_json
        expected = {
          id: "1", type: :profiles,
          attributes: { name: "name", summary: "description" },
          relationships: {
           child_records: { links: { related: "https://example.com/comments/index?filter[parent_record_id]=1" } } ,
           child_record: { data: { id: "3", type: "posts" }, links: { related: "https://example.com/posts/show/3" } },
},
          links: { self: "https://example.com/profiles/show/1" }
        }.to_json
        assert_equal expected, @serializer_instance.to_json
      end

      def test_record_instance_dump
        expected = {
          id: "1", type: :profiles
        }.to_json
        assert_equal expected, @serializer_instance.dump(id: "1", type: :profiles)
      end
    end
  end
end
