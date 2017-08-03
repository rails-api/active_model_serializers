class SerializableComment < JSONAPI::Serializable::Resource
  type 'comments'

  attributes :author, :comment

  belongs_to :post, class: 'SerializablePost'
end
