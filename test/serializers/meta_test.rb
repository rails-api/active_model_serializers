require 'test_helper'

module ActiveModel
  class Serializer
    class MetaTest < Minitest::Test
      def setup
        ActionController::Base.cache_store.clear
        @blog = Blog.new(id: 1,
                         name: 'AMS Hints',
                         writer: Author.new(id: 2, name: "Steve"),
                         articles: [Post.new(id: 3, title: "AMS")])
      end

      def test_meta_is_present_with_root
        adapter = load_adapter(root: "blog", meta: {total: 10})
        expected = {
          "blog" => {
            id: 1,
            title: "AMS Hints"
          },
          "meta" => {
            total: 10
          }
        }
        assert_equal expected, adapter.as_json
      end

      def test_meta_is_not_included_when_root_is_missing
        adapter = load_adapter(meta: {total: 10})
        expected = {
          id: 1,
          title: "AMS Hints"
        }
        assert_equal expected, adapter.as_json
      end

      def test_meta_key_is_used
        adapter = load_adapter(root: "blog", meta: {total: 10}, meta_key: "haha_meta")
        expected = {
          "blog" => {
            id: 1,
            title: "AMS Hints"
          },
          "haha_meta" => {
            total: 10
          }
        }
        assert_equal expected, adapter.as_json
      end

      def test_meta_is_not_present_on_arrays_without_root
        serializer = ArraySerializer.new([@blog], meta: {total: 10})
        adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)
        expected = [{
          id: 1,
          name: "AMS Hints",
          writer: {
            id: 2,
            name: "Steve"
          },
          articles: [{
            id: 3,
            title: "AMS",
            body: nil
          }]
        }]
        assert_equal expected, adapter.as_json
      end

      def test_meta_is_present_on_arrays_with_root
        serializer = ArraySerializer.new([@blog], meta: {total: 10}, meta_key: "haha_meta")
        adapter = ActiveModel::Serializer::Adapter::Json.new(serializer, root: 'blog')
        expected = {
          'blog' => [{
            id: 1,
            name: "AMS Hints",
            writer: {
              id: 2,
              name: "Steve"
            },
            articles: [{
              id: 3,
              title: "AMS",
              body: nil
            }]
          }],
          'haha_meta' => {
            total: 10
          }
        }
        assert_equal expected, adapter.as_json
      end

      private

      def load_adapter(options)
        adapter_opts, serializer_opts =
          options.partition { |k, _| ActionController::Serialization::ADAPTER_OPTION_KEYS.include? k }.map { |h| Hash[h] }

        serializer = AlternateBlogSerializer.new(@blog, serializer_opts)
        ActiveModel::Serializer::Adapter::Json.new(serializer, adapter_opts)
      end
    end
  end
end
