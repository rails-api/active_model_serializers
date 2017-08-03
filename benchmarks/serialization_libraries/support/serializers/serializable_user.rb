class SerializableUser < JSONAPI::Serializable::Resource
  type 'users'


  attributes :first_name, :last_name, :birthday,
             :created_at, :updated_at

  has_many :posts, class: 'SerializablePost'
end
