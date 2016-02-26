class PostController < ActionController::Base
  POST =
    begin
      comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
      author  = Author.new(id: 1, name: 'Joao Moura.')
      Post.new(id: 1, title: 'New Post', blog: nil, body: 'Body', comments: [comment], author: author)
    end

  def render_with_caching_serializer
    toggle_cache_status
    render json: POST, serializer: CachingPostSerializer, adapter: :json, meta: { caching: perform_caching }
  end

  def render_with_non_caching_serializer
    toggle_cache_status
    render json: POST, adapter: :json, meta: { caching: perform_caching }
  end

  def render_cache_status
    toggle_cache_status
    # Uncomment to debug
    # STDERR.puts cache_store.class
    # STDERR.puts cache_dependencies
    # ActiveSupport::Cache::Store.logger.debug [ActiveModelSerializers.config.cache_store, ActiveModelSerializers.config.perform_caching, CachingPostSerializer._cache, perform_caching, params].inspect
    render json: { caching: perform_caching, meta: { cache_log: cache_messages, cache_status: cache_status } }.to_json
  end

  def clear
    ActionController::Base.cache_store.clear
    # Test caching is on
    # logger = DummyLogger.new
    # ActiveSupport::Cache::Store.logger = logger # seems to be the best way
    # the below is used in some rails tests but isn't available/working in all versions, so far as I can tell
    # https://github.com/rails/rails/pull/15943
    # ActiveSupport::Notifications.subscribe(/^cache_(.*)\.active_support$/) do |*args|
    #   logger.debug ActiveSupport::Notifications::Event.new(*args)
    # end
    render json: 'ok'.to_json
  end

  private

  def cache_status
    {
      controller: perform_caching,
      app: Rails.configuration.action_controller.perform_caching,
      serializers: Rails.configuration.serializers.each_with_object({}) { |serializer, data| data[serializer.name] = serializer._cache.present? }
    }
  end

  def cache_messages
    ActiveSupport::Cache::Store.logger.is_a?(DummyLogger) && ActiveSupport::Cache::Store.logger.messages.split("\n")
  end

  def toggle_cache_status
    case params[:on]
    when 'on'.freeze then self.perform_caching = true
    when 'off'.freeze then self.perform_caching = false
    else nil # no-op
    end
  end
end

Rails.application.routes.draw do
  get '/status(/:on)' => 'post#render_cache_status'
  get '/clear' => 'post#clear'
  get '/caching(/:on)' => 'post#render_with_caching_serializer'
  get '/non_caching(/:on)' => 'post#render_with_non_caching_serializer'
end
