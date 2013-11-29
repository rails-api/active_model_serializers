require 'test_helper'
require 'fixtures/active_record'

module ActiveModel
  class XmlSerializer
    class ActiveRecordTest < ActiveModel::TestCase
      def setup
        @post = ARPost.first
      end

      def test_serialization_embedding_objects
        post_serializer = ARPostSerializer.new(@post)

        assert_equal({
          title: 'New post', body: 'A body!!!',
          ar_comments: [{ body: 'what a dumb post', ar_tags: [{ name: 'short' }, { name: 'whiny' }] },
                        { body: 'i liked it', ar_tags: [{:name=>"short"}, {:name=>"happy"}] }],
          ar_tags: [{ name: 'short' }, { name: 'whiny' }, { name: 'happy' }],
          ar_section: { 'name' => 'ruby' }
        }.to_xml(root: 'ar_post'), post_serializer.as_xml)
      end

      def test_serialization_embedding_ids
        post_serializer = ARPostSerializer.new(@post)

        embed(ARPostSerializer, embed: :ids) do
          assert_equal({
            title: 'New post', body: 'A body!!!',
            'ar_comment_ids' => [1, 2],
            'ar_tag_ids' => [1, 2, 3],
            'ar_section_id' => 1
          }.to_xml(root: 'ar_post'), post_serializer.as_xml)
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
            'ar_sections' => [{ 'name' => 'ruby' }]
          }.to_xml, post_serializer.as_xml)
        end
      end

      private

      def embed(serializer_class, options = {})
        old_assocs = Hash[serializer_class._associations.to_a.map { |(name, association)| [name, association.dup] }]

        serializer_class._associations.each_value do |association|
          association.embed = options[:embed]
          association.embed_in_root = options[:embed_in_root]
        end

        yield
      ensure
        serializer_class._associations = old_assocs
      end
    end
  end
end
