require 'test_helper'
require 'fixtures/active_record'

module ActiveModel
  class Serializer
    class ActiveRecordTest < Minitest::Test
      def setup
        @post = ARPost.first

        @task = ARTask.first

      end

      def test_serialization_embedding_objects
        post_serializer = ARPostSerializer.new(@post)

        assert_equal({
          'ar_post' => {
            title: 'New post', body: 'A body!!!',
            ar_comments: [{ body: 'what a dumb post', ar_tags: [{ name: 'happy' }, { name: 'whiny' }] },
                          { body: 'i liked it', ar_tags: [{:name=>"happy"}, {:name=>"short"}] }],
            ar_tags: [{ name: 'short' }, { name: 'whiny' }],
            ar_section: { 'name' => 'ruby' }
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
              'ar_tag_ids' => [1, 2],
              'ar_section_id' => 1
            }
          }, post_serializer.as_json)
        end
      end

      def test_serialization_embedding_ids_including_in_root
        post_serializer = ARPostSerializer.new(@post)

        embed(ARPostSerializer, embed: :ids, embed_in_root: true) do
          embed(ARCommentSerializer, embed: :ids, embed_in_root: true) do
            assert_equal({
              'ar_post' => {
                title: 'New post', body: 'A body!!!',
                'ar_comment_ids' => [1, 2],
                'ar_tag_ids' => [1, 2],
                'ar_section_id' => 1
              },
              ar_comments: [{ body: 'what a dumb post', 'ar_tag_ids' => [3, 2] },
                            { body: 'i liked it', 'ar_tag_ids' => [3, 1] }],
              ar_tags: [{ name: 'happy' }, { name: 'whiny' }, { name: 'short' }],
              'ar_sections' => [{ 'name' => 'ruby' }]
            }, post_serializer.as_json)
          end
        end
      end

      def test_serialization_polymorphic_has_one_wrapped_in_array
        task_serializer = ARTaskSerializer.new(@task)

        assert_equal({
          'ar_task' => {
            name: 'task',
            ar_list: [
              { name: 'list for task', ar_items: [
                { description: 'task list item'}
              ]}
            ]       
          }
        }, task_serializer.as_json)

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
