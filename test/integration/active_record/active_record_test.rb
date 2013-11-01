require 'test_helper'
require 'fixtures/active_record'

module ActiveModel
  class Serializer
    class ActiveRecordTest < ActiveModel::TestCase
      def setup
        @post = ARPost.first
      end

      def test_serialization_embedding_objects
        post_serializer = ARPostSerializer.new(@post)

        assert_equal({
          'ar_post' => {
            title: 'New post', body: 'A body!!!',
            ar_comments: [{ body: 'what a dumb post', ar_tags: [{ name: 'short' }, { name: 'whiny' }] },
                          { body: 'i liked it', ar_tags: [{:name=>"short"}, {:name=>"happy"}] }],
            ar_tags: [{ name: 'short' }, { name: 'whiny' }, { name: 'happy' }],
            ar_sections: [{ 'name' => 'ruby' }]
          }
        }, post_serializer.as_json)
      end

      def test_serialization_embedding_ids
        post_serializer = ARPostSerializer.new(@post)

        embed(ARPostSerializer, embed: :ids) do
          assert_equal({
            'ar_post' => {
              title: 'New post', body: 'A body!!!',
              'ar_comment_ids' => [1, 2],
              'ar_tag_ids' => [1, 2, 3],
              'ar_section_id' => 1
            }
          }, post_serializer.as_json)
        end
      end

      def test_serialization_embedding_ids_including_in_root
        post_serializer = ARPostSerializer.new(@post)

        embed(ARPostSerializer, embed: :ids, embed_in_root: true) do
          assert_equal({
            'ar_post' => {
              title: 'New post', body: 'A body!!!',
              'ar_comment_ids' => [1, 2],
              'ar_tag_ids' => [1, 2, 3],
              'ar_section_id' => 1
            },
            ar_comments: [{ body: 'what a dumb post', ar_tags: [{ name: 'short' }, { name: 'whiny' }] },
                          { body: 'i liked it', ar_tags: [{:name=>"short"}, {:name=>"happy"}] }],
            ar_tags: [{ name: 'short' }, { name: 'whiny' }, { name: 'happy' }],
            ar_sections: [{ 'name' => 'ruby' }]
          }, post_serializer.as_json)
        end
      end

      private

      def embed(klass, options = {})
        old_assocs = Hash[ARPostSerializer._associations.to_a.map { |(name, association)| [name, association.dup] }]

        ARPostSerializer._associations.each_value do |association|
          association.embed = options[:embed]
          association.embed_in_root = options[:embed_in_root]
        end

        yield
      ensure
        ARPostSerializer._associations = old_assocs
      end
    end
  end
end
