class Model
  def initialize(hash={})
    @attributes = hash
  end

  def read_attribute_for_serialization(name)
    if name == :id || name == 'id'
      object_id
    else
      @attributes[name]
    end
  end
end

class Profile < Model
end

class ProfileSerializer < ActiveModel::Serializer
  attributes :name, :description
end
