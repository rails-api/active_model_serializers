require "test_helper"
require "test_fakes"

class HalArraySerializerTest < ActiveModel::TestCase
  def test_no_root_by_default
    user1 = HalUser.new
    user2 = HalUser.new(first_name: 'Steve', last_name: 'Klabnik')
    user3 = HalUser.new(first_name: 'Yehuda', last_name: 'Katz')

    user_serializer = HalUsersSerializer.new([user1, user2, user3])

    hash = user_serializer.as_json

    assert_equal({
      _embedded: {
        hal_users: [
          { first_name: 'Jose', last_name: 'Valim' },
          { first_name: 'Steve', last_name: 'Klabnik' },
          { first_name: 'Yehuda', last_name: 'Katz' }
        ]
      }
    }, hash)
  end

  def test_link_method
    user1 = HalUser.new
    user2 = HalUser.new(first_name: 'Steve', last_name: 'Klabnik')
    user3 = HalUser.new(first_name: 'Yehuda', last_name: 'Katz')

    user_serializer = HalUsersSerializerWithLink.new([user1, user2, user3])

    hash = user_serializer.as_json

    assert_equal({ href: '/bar' }, hash[:_links][:foo])
  end
end
