require "test_helper"
require "test_fakes"

class HalSerializerTest < ActiveModel::TestCase
  def test_no_root_by_default
    user = User.new
    user_serializer = HalUserSerializer.new(user)

    hash = user_serializer.as_json

    assert_equal({
      first_name: 'Jose', last_name: 'Valim'
    }, hash)
  end

  def test_link_method
    user = User.new
    user_serializer = HalUserSerializerWithLink.new(user)

    hash = user_serializer.as_json

    assert_equal({ href: '/bar' }, hash[:_links][:foo])
  end
end
