class Model
  def initialize(hash={})
    @attributes = hash
  end

  def read_attribute_for_serialization(name)
    @attributes[name]
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
