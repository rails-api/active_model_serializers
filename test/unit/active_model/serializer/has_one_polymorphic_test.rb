require 'test_helper'

module ActiveModel
  class Serializer
    class HasOnePolymorphicTest < ActiveModel::TestCase
      def setup
        @association = InterviewSerializer._associations[:attachment]
        @old_association = @association.dup

        @interview = Interview.new({ text: 'Text 1' })
        @interview_serializer = InterviewSerializer.new(@interview)
      end

      def teardown
        InterviewSerializer._associations[:attachment] = @old_association
      end

      def model_name(object)
        object.class.to_s.demodulize.underscore.to_sym
      end

      def test_associations_definition
        assert_equal 1, InterviewSerializer._associations.length
        assert_kind_of Association::HasOne, @association
        assert_equal true, @association.polymorphic
        assert_equal 'attachment', @association.name
      end

      def test_associations_embedding_ids_serialization_using_serializable_hash
        @association.embed = :ids

        assert_equal({
          text: 'Text 1',
          'attachment_id' => {
            type: model_name(@interview.attachment),
            id: @interview.attachment.object_id
          }
        }, @interview_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_serialization_using_as_json
        @association.embed = :ids

        assert_equal({
          'interview' => {
            text: 'Text 1',
            'attachment_id' => {
              type: model_name(@interview.attachment),
              id: @interview.attachment.object_id
            }
          }
        }, @interview_serializer.as_json)
      end

      def test_associations_embedding_ids_serialization_using_serializable_hash_and_key_from_options
        @association.embed = :ids
        @association.key = 'key'

        assert_equal({
          text: 'Text 1',
          'key' => {
            type: model_name(@interview.attachment),
            id: @interview.attachment.object_id
          }
        }, @interview_serializer.serializable_hash)
      end

      def test_associations_embedding_objects_serialization_using_serializable_hash
        @association.embed = :objects

        assert_equal({
          text: 'Text 1',
          attachment: {
            type: model_name(@interview.attachment),
            model_name(@interview.attachment) => { url: 'U1'}
          }
        }, @interview_serializer.serializable_hash)
      end

      def test_associations_embedding_objects_serialization_using_as_json
        @association.embed = :objects

        assert_equal({
          'interview' => {
            text: 'Text 1',
            attachment: {
              type: model_name(@interview.attachment),
              model_name(@interview.attachment) => { url: 'U1'}
            }
          }
        }, @interview_serializer.as_json)
      end

      def test_associations_embedding_nil_ids_serialization_using_as_json
        @association.embed = :ids
        @interview.instance_eval do
          def attachment
            nil
          end
        end

        assert_equal({
          'interview' => { text: 'Text 1', 'attachment_id' => nil }
        }, @interview_serializer.as_json)
      end

      def test_associations_embedding_nil_objects_serialization_using_as_json
        @association.embed = :objects
        @interview.instance_eval do
          def attachment
            nil
          end
        end

        assert_equal({
          'interview' => { text: 'Text 1', attachment: nil }
        }, @interview_serializer.as_json)
      end

      def test_associations_embedding_objects_serialization_using_serializable_hash_and_root_from_options
        @association.embed = :objects
        @association.embedded_key = 'root'

        assert_equal({
          text: 'Text 1',
          'root' => {
            type: model_name(@interview.attachment),
            model_name(@interview.attachment) => { url: 'U1'}
          }
        }, @interview_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_serializable_hash
        @association.embed = :ids
        @association.embed_in_root = true

        assert_equal({
          text: 'Text 1',
          'attachment_id' => {
            type: model_name(@interview.attachment),
            id: @interview.attachment.object_id
          }
        }, @interview_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_as_json
        @association.embed = :ids
        @association.embed_in_root = true

        assert_equal({
          'interview' => {
            text: 'Text 1',
            'attachment_id' => {
              type: model_name(@interview.attachment),
              id: @interview.attachment.object_id
            }
          },
          "attachments" => [{
            type: model_name(@interview.attachment),
            model_name(@interview.attachment) => {
              url: 'U1'
            }
          }]
        }, @interview_serializer.as_json)
      end

      def test_associations_using_a_given_serializer
        @association.embed = :ids
        @association.embed_in_root = true
        @association.serializer_from_options = Class.new(ActiveModel::Serializer) do
          def name
            'fake'
          end

          attributes :name
        end

        assert_equal({
          'interview' => {
            text: 'Text 1',
            'attachment_id' => {
              type: model_name(@interview.attachment),
              id: @interview.attachment.object_id
            }
          },
          "attachments" => [{
            type: model_name(@interview.attachment),
            model_name(@interview.attachment) => {
              name: 'fake'
            }
          }]
        }, @interview_serializer.as_json)
      end
    end
  end
end
