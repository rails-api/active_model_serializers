require 'test_helper'

class ActiveRecordTest < ActiveSupport::TestCase
  include ActiveModel::Serializer::Lint::Tests

  def setup
    @resource = ARModels::Post.new
    @image = Image.create
  end

  def test_active_model_record_with_validated_polymorphic_relationship_creation
    picture = Picture.create!(picture_params)

    assert_equal(@image, picture.imageable)
  end

  private

  def picture_params
    params = ActionController::Parameters.new({
      data: {
        attributes: {
          title: 'Picture Title'
        },
        relationships: {
          imageable: {
            data: {
              type: 'images',
              id: @image.id
            }
          },
        },
        type: 'pictures'
      }
    })

    ActiveModelSerializers::Deserialization.jsonapi_parse!(
      params.to_unsafe_h,
      polymorphic: [:imageable]
    )
  end
end
