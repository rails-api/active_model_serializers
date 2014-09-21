require 'test_helper'

module ActiveModel
  class Serializer
    class HasManyPolymorphicTest < ActiveModel::TestCase
      def setup
        @association = MailSerializer._associations[:attachments]
        @old_association = @association.dup

        @mail = Mail.new({ body: 'Body 1' })
        @mail_serializer = MailSerializer.new(@mail)
      end

      def teardown
        MailSerializer._associations[:attachments] = @old_association
      end

      def model_name(object)
        object.class.to_s.demodulize.underscore.to_sym
      end

      def test_associations_definition
        assert_equal 1, MailSerializer._associations.length
        assert_kind_of Association::HasMany, @association
        assert_equal true, @association.polymorphic
        assert_equal 'attachments', @association.name
      end

      def test_associations_embedding_ids_serialization_using_serializable_hash
        @association.embed = :ids

        assert_equal({
          body: 'Body 1',
          'attachment_ids' => @mail.attachments.map do |c|
            { id: c.object_id, type: model_name(c) }
          end
        }, @mail_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_serialization_using_as_json
        @association.embed = :ids

        assert_equal({
          'mail' => {
            :body => 'Body 1',
            'attachment_ids' => @mail.attachments.map do |c|
              { id: c.object_id, type: model_name(c) }
            end
          }
        }, @mail_serializer.as_json)
      end

      def test_associations_embedding_ids_serialization_using_serializable_hash_and_key_from_options
        @association.embed = :ids
        @association.key = 'key'

        assert_equal({
          body: 'Body 1',
          'key' => @mail.attachments.map do |c|
            { id: c.object_id, type: model_name(c) }
          end
        }, @mail_serializer.serializable_hash)
      end

      def test_associations_embedding_objects_serialization_using_serializable_hash
        @association.embed = :objects

        assert_equal({
          body: 'Body 1',
          :attachments => [
            { type: :image, image: { url: 'U1' }},
            { type: :video, video: { html: 'H1' }}
          ]
        }, @mail_serializer.serializable_hash)
      end

      def test_associations_embedding_objects_serialization_using_as_json
        @association.embed = :objects

        assert_equal({
          'mail' => {
            body: 'Body 1',
            attachments: [
              { type: :image, image: { url: 'U1' }},
              { type: :video, video: { html: 'H1' }}
            ]
          }
        }, @mail_serializer.as_json)
      end

      def test_associations_embedding_nil_objects_serialization_using_as_json
        @association.embed = :objects
        @mail.instance_eval do
          def attachments
            [nil]
          end
        end

        assert_equal({
          'mail' => {
            :body => 'Body 1',
            :attachments => [nil]
          }
        }, @mail_serializer.as_json)
      end

      def test_associations_embedding_objects_serialization_using_serializable_hash_and_root_from_options
        @association.embed = :objects
        @association.embedded_key = 'root'

        assert_equal({
          body: 'Body 1',
          'root' => [
            { type: :image, image: { url: 'U1' }},
            { type: :video, video: { html: 'H1' }}
          ]
        }, @mail_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_serializable_hash
        @association.embed = :ids
        @association.embed_in_root = true

        assert_equal({
          body: 'Body 1',
          'attachment_ids' => @mail.attachments.map do |c|
            { id: c.object_id, type: model_name(c) }
          end
        }, @mail_serializer.serializable_hash)
      end

      def test_associations_embedding_ids_including_objects_serialization_using_as_json
        @association.embed = :ids
        @association.embed_in_root = true

        assert_equal({
          'mail' => {
            body: 'Body 1',
            'attachment_ids' => @mail.attachments.map do |c|
              { id: c.object_id, type: model_name(c) }
            end,
          },
          'attachments' => [
            { type: :image, image: { url: 'U1' }},
            { type: :video, video: { html: 'H1' }}
          ]
        }, @mail_serializer.as_json)
      end

      def test_associations_embedding_nothing_including_objects_serialization_using_as_json
        @association.embed = nil
        @association.embed_in_root = true

        assert_equal({
          'mail' => { body: 'Body 1' },
          'attachments' => [
            { type: :image, image: { url: 'U1' }},
            { type: :video, video: { html: 'H1' }}
          ]
        }, @mail_serializer.as_json)
      end

      def test_associations_using_a_given_serializer
        @association.embed = :ids
        @association.embed_in_root = true
        @association.serializer_from_options = Class.new(ActiveModel::Serializer) do
          def fake
            'fake'
          end

          attributes :fake
        end

        assert_equal({
          'mail' => {
            body: 'Body 1',
            'attachment_ids' => @mail.attachments.map do |c|
              { id: c.object_id, type: model_name(c) }
            end
          },
          'attachments' => [
            { type: :image, image: { fake: 'fake' }},
            { type: :video, video: { fake: 'fake' }}
          ]
        }, @mail_serializer.as_json)
      end
    end
  end
end
