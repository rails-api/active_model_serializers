require 'test_helper'

module ActiveModel
  class Serializer
    class AssociationCircularReferenceTest < Minitest::Test
      def test_circular_has_one_associations
        user = User.new(id: 1, name: 'Ian')
        user.profile.user = user
        hsh = HasOneCircularReference::UserSerializer.new(user).as_json.symbolize_keys

        user_hsh = hsh[:user]
        profile_hsh = user_hsh[:profile]
        profile_user_hsh = profile_hsh[:user]

        assert_equal user_hsh[:id], profile_user_hsh[:id]
        assert_nil profile_user_hsh[:user]
      end

      def test_circular_has_one_associations_embedded_in_root
        user = User.new(id: 1, name: 'Ian')
        user.profile.user = user
        hsh = HasOneCircularReference::EmbeddedInRoot::UserSerializer.new(user).as_json.symbolize_keys

        user_hsh = hsh[:user].symbolize_keys
        assert_equal user_hsh[:profile], hsh[:profiles].first[:id]

        profile_hsh = hsh[:profiles].first.symbolize_keys
        assert_equal profile_hsh[:user], user_hsh[:id]

        linked_user_hsh = hsh[:users].first.symbolize_keys
        assert_equal user_hsh[:id], linked_user_hsh[:id]
      end

      def test_circular_has_many_associations
        category = Category.new(name: 'C1')
        post = Post.new(title: 'T1', body: 'B1')
        post.category = category
        category.instance_variable_set("@posts", [post])

        hsh = HasManyCircularReference::CategorySerializer.new(category).as_json.symbolize_keys

        category_hsh = hsh[:category]
        post_hsh = category_hsh[:posts].first
        post_category_hsh = post_hsh[:category]

        assert_equal category_hsh[:id], post_category_hsh[:id]
        assert_nil post_category_hsh[:posts]
      end

      def test_circular_has_many_associations_embedded_in_root
        category = Category.new(name: 'C1')
        post = Post.new(title: 'T1', body: 'B1')
        post.category = category
        category.instance_variable_set("@posts", [post])
        hsh = HasManyCircularReference::EmbeddedInRoot::CategorySerializer.new(category).as_json.symbolize_keys

        category_hsh = hsh[:category].symbolize_keys
        post_hsh = hsh[:posts].first.symbolize_keys
        assert_equal category_hsh[:posts].first, post_hsh[:id]
        assert_equal post_hsh[:category], category_hsh[:id]

        linked_category_hsh = hsh[:categories].first.symbolize_keys
        assert_equal linked_category_hsh[:id], post_hsh[:category]
        assert_equal linked_category_hsh[:posts].first, post_hsh[:id]
      end
    end
  end
end
