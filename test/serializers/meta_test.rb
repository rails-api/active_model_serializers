require 'test_helper'

module ActiveModel
  class Serializer
    class MetaTest < Minitest::Test
      def setup
        ActionController::Base.cache_store.clear
        @blog = Blog.new(id: 1,
                         name: 'AMS Hints',
                         writer: Author.new(id: 2, name: 'Steve'),
                         articles: [Post.new(id: 3, title: 'AMS')])
      end

      def test_meta_is_present_with_root
        serializer = AlternateBlogSerializer.new(@blog, meta: { total: 10 })
        adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)
        expected = {
          blog: {
            id: 1,
            title: 'AMS Hints'
          },
          'meta' => {
            total: 10
          }
        }
        assert_equal expected, adapter.as_json
      end

      def test_meta_is_not_included_when_root_is_missing
        # load_adapter uses FlattenJson Adapter
        adapter = load_adapter(meta: { total: 10 })
        expected = {
          id: 1,
          title: 'AMS Hints'
        }
        assert_equal expected, adapter.as_json
      end

      def test_meta_key_is_used
        serializer = AlternateBlogSerializer.new(@blog, meta: { total: 10 }, meta_key: 'haha_meta')
        adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)
        expected = {
          blog: {
            id: 1,
            title: 'AMS Hints'
          },
          'haha_meta' => {
            total: 10
          }
        }
        assert_equal expected, adapter.as_json
      end

      def test_meta_key_is_used_with_json_api
        serializer = AlternateBlogSerializer.new(@blog, meta: { total: 10 }, meta_key: 'haha_meta')
        adapter = ActiveModel::Serializer::Adapter::JsonApi.new(serializer)
        expected = {
          data: {
            id: '1',
            type: 'blogs',
            attributes: { title: 'AMS Hints' }
          },
          'haha_meta' => { total: 10 }
        }
        assert_equal expected, adapter.as_json
      end

      def test_meta_is_not_present_on_arrays_without_root
        serializer = ArraySerializer.new([@blog], meta: { total: 10 })
        # FlattenJSON doesn't have support to root
        adapter = ActiveModel::Serializer::Adapter::FlattenJson.new(serializer)
        expected = [{
          id: 1,
          name: 'AMS Hints',
          writer: {
            id: 2,
            name: 'Steve'
          },
          articles: [{
            id: 3,
            title: 'AMS',
            body: nil
          }]
        }]
        assert_equal expected, adapter.as_json
      end

      def test_meta_is_present_on_arrays_with_root
        serializer = ArraySerializer.new([@blog], meta: { total: 10 }, meta_key: 'haha_meta')
        # JSON adapter adds root by default
        adapter = ActiveModel::Serializer::Adapter::Json.new(serializer)
        expected = {
          blogs: [{
            id: 1,
            name: 'AMS Hints',
            writer: {
              id: 2,
              name: 'Steve'
            },
            articles: [{
              id: 3,
              title: 'AMS',
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
        options = options.merge(adapter: :flatten_json, serializer: AlternateBlogSerializer)
        ActiveModel::SerializableResource.new(@blog, options)
      end
    end
  end
end
