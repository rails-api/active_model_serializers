module BenchHelper
  module_function

  def clear_data
    Comment.delete_all
    Post.delete_all
    User.delete_all
  end

  def seed_data
    data_config = {
      comments_per_post: 2,
      posts: 20
    }

    anchor_time = Time.new(2017,7,1).utc
    user = User.create(first_name: 'Diana', last_name: 'Prince', birthday: anchor_time, created_at: anchor_time, updated_at: anchor_time)

    data_config[:posts].times do
      post = Post.create(user_id: user.id, title: 'Some Post', body: 'awesome content', created_at: anchor_time, updated_at: anchor_time)
      data_config[:comments_per_post].times do
        Comment.create(author: 'me', comment: 'nice blog', post_id: post.id, created_at: anchor_time, updated_at: anchor_time)
      end
    end
  end

  def test_render(render_gem)
    render_data(
      User.first,
      render_gem
    )
  end

  def test_manual_eagerload(render_gem)
    render_data(
      User.includes(posts: [:comments]).first,
      render_gem
    )
  end

  # protected

  def render_data(data, render_gem)
    case render_gem
    when :ams then render_with_ams(data)
    when :jsonapi_rb then render_with_jsonapi_rb(data)
    else fail ArgumentError, "Cannot render unknown gem '#{render_gem.inspect}'"
    end
  end

  def render_with_ams(data)
    ActiveModelSerializers::SerializableResource.new(
      data,
      include: 'posts.comments',
      adapter: :json_api
    ).as_json
  end

  def render_with_jsonapi_rb(data)
    JSONAPI::Serializable::Renderer.new.render(
      data,
      include: 'posts.comments',
      class: { User: SerializableUser, Post: SerializablePost, Comment: SerializableComment }
    )
  end
end
