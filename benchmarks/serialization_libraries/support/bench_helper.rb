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

    u = User.create(first_name: 'Diana', last_name: 'Prince', birthday: 3000.years.ago)

    data_config[:posts].times do
      p = Post.create(user_id: u.id, title: 'Some Post', body: 'awesome content')
      data_config[:comments_per_post].times do
        Comment.create(author: 'me', comment: 'nice blog', post_id: p.id)
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

  def render_data(data, render_gem)
    return render_with_ams(data) if render_gem == :ams

    render_with_jsonapi_rb(data)
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
