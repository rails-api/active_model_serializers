class CommentSerializer < ActiveModel::Serializer
  attributes :id,
             :author, :comment

  belongs_to :post#, serializer: PostSerializer
end
