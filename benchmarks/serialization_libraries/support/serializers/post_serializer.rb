class PostSerializer < ActiveModel::Serializer
  attributes :id,
             :title, :body,
             :created_at, :updated_at

  belongs_to :user#, serializer: UserSerializer
  has_many :comments#, each_serializer: CommentSerializer
end
