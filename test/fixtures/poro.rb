class Model
  def initialize(hash={})
    @attributes = hash
  end

  def read_attribute_for_serialization(name)
    @attributes[name]
  end

  def model
    @model ||= Model.new(attr1: 'v1', attr2: 'v2')
  end

  def id
    object_id
  end
end

class ModelSerializer < ActiveModel::Serializer
  def attr2
    attr2 = object.read_attribute_for_serialization(:attr2)
    if scope
      attr2 + '-' + scope
    else
      attr2
    end
  end

  attributes :attr1, :attr2
end

class AnotherSerializer < ActiveModel::Serializer
  attributes :attr2, :attr3

  has_one :model
end
