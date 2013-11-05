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

  def test_link_method_with_block
    user = User.new
    user_serializer = HalUserSerializerWithLinkBlock.new(user)

    hash = user_serializer.as_json

    assert_equal({ href: '/names/Jose' }, hash[:_links][:name])
  end

  def test_has_many_method
    post = Post.new(title: "New Post", body: "Body of new post", email: "tenderlove@tenderlove.com")
    comments = [Comment.new(title: "Comment1"), Comment.new(title: "Comment2")]
    post.comments = comments

    post_serializer = HalPostSerializer.new(post)

    assert_equal({
      title:  'New Post',
      body:   'Body of new post',
      _embedded: {
        comments: [
          { title: 'Comment1' },
          { title: 'Comment2' }
        ]
      }
    }, post_serializer.as_json)
  end

  def test_has_one_method
    user = User.new
    blog = Blog.new
    blog.author = user

    blog_serializer = HalBlogSerializer.new(blog)
    assert_equal({
      _embedded: {
        author: {
          first_name: 'Jose',
          last_name: 'Valim'
        }
      }
    }, blog_serializer.as_json)
  end
end
