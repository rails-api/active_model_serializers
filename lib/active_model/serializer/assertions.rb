# TODO: move this into active_model_serializers gem
module ActiveModel::Serializer::Assertions
  def assert_serializer(serializer, message = nil)
    msg = message || sprintf("expecting %s serializer to be used", serializer.to_s)
    rendered_serializer = ActiveModel::Serializer::Integrations::RSpec.serializers.any? { |s,num| s == serializer }
    assert rendered_serializer, msg
  end
end
