class Model
  def initialize(hash={})
    @attributes = hash
  end
end

class Profile < Model
end

class ProfileSerializer < ActiveModel::Serializer
  attributes :name, :description
end
