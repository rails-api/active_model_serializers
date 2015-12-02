require 'active_model/serializer/error_serializer'
class ActiveModel::Serializer::ErrorsSerializer < ActiveModel::Serializer
  include Enumerable
  delegate :each, to: :@serializers
  attr_reader :object, :root

  def initialize(resources, options = {})
    @root = options[:root]
    @object = resources
    @serializers = resources.map do |resource|
      serializer_class = options.fetch(:serializer) { ActiveModel::Serializer::ErrorSerializer }
      serializer_class.new(resource, options.except(:serializer))
    end
  end

  def json_key
    nil
  end

  protected

  attr_reader :serializers
end
