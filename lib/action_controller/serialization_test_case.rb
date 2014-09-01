module ActionController
  module SerializationAssertions
    extend ActiveSupport::Concern

    included do
      setup :setup_serialization_subscriptions
      teardown :teardown_serialization_subscriptions
    end

    def setup_serialization_subscriptions
      @serializers = Hash.new(0)

      ActiveSupport::Notifications.subscribe("!serialize.active_model_serializers") do |name, start, finish, id, payload|
        serializer = payload[:serializer]
        @serializers[serializer] += 1
      end
    end

    def teardown_serialization_subscriptions
      ActiveSupport::Notifications.unsubscribe("!serialize.active_model_serializers")
    end

    def process(*args)
      @serializers = Hash.new(0)
      super
    end

    # Asserts that the request was rendered with the appropriate serializers.
    #
    #  # assert that the "PostSerializer" serializer was rendered
    #  assert_serializer "PostSerializer"
    #
    #  # assert that the instance of PostSerializer was rendered
    #  assert_serializer PostSerializer
    #
    #  # assert that the "PostSerializer" serializer was rendered
    #  assert_serializer :post_serializer
    #
    #  # assert that the rendered serializer starts with "Post"
    #  assert_serializer %r{\APost.+\Z}
    #
    #  # assert that no serializer was rendered
    #  assert_serializer nil
    #
    #
    def assert_serializer(options = {}, message = nil)
      # Force body to be read in case the template is being streamed.
      response.body

      rendered = @serializers
      msg = message || "expecting <#{options.inspect}> but rendering with <#{rendered.keys}>"

      matches_serializer = case options
                           when lambda { |options| options.kind_of?(Class) && options < ActiveModel::Serializer }
                             rendered.any? do |serializer, count|
                               options.name == serializer
                             end
                           when Symbol
                             options = options.to_s.camelize
                             rendered.any? do |serializer, count|
                               serializer == options
                             end
                           when String
                             !options.empty? && rendered.any? do |serializer, count|
                               serializer == options
                             end
                           when Regexp
                             rendered.any? do |serializer, count|
                               serializer.match(options)
                             end
                           when NilClass
                             rendered.blank?
                           else
                             raise ArgumentError, "assert_serializer only accepts a String, Symbol, Regexp, ActiveModel::Serializer, or nil"
                           end
      assert matches_serializer, msg
    end
  end
end
