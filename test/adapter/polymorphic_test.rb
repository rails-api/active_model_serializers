require 'test_helper'

module ActiveModel
  class Serializer
    module Adapter
      class PolymorphicTest < ActiveSupport::TestCase
        setup do
          @employee = Employee.new(id: 42, name: 'Zoop Zoopler', email: 'zoop@example.com')
          @picture = @employee.pictures.new(id: 1, title: 'headshot-1.jpg')
          @picture.imageable = @employee

          @attributes_serialization = serializable(@picture, serializer: PolymorphicBelongsToSerializer) # uses default adapter: attributes
          @json_serialization = serializable(@picture, adapter: :json, serializer: PolymorphicBelongsToSerializer)
          @json_api_serialization = serializable(@picture, adapter: :json_api, serializer: PolymorphicBelongsToSerializer)
        end

        def test_attributes_serialization
          expected =
            {
              id: 1,
              title: 'headshot-1.jpg',
              imageable: {
                id: 42,
                name: 'Zoop Zoopler'
              }
            }

          assert_equal(expected, @attributes_serialization.as_json)
        end

        def test_json_serializer
          expected =
            {
              picture: {
                id: 1,
                title: 'headshot-1.jpg',
                imageable: {
                  id: 42,
                  name: 'Zoop Zoopler'
                }
              }
            }

          assert_equal(expected, @json_serialization.as_json)
        end

        def test_json_api_serializer
          expected =
            {
              data: {
                id: '1',
                type: 'pictures',
                attributes: {
                  title: 'headshot-1.jpg'
                },
                relationships: {
                  imageable: {
                    data: {
                      id: '42',
                      type: 'employees'
                    }
                  }
                }
              }
            }

          assert_equal(expected, @json_api_serialization.as_json)
        end
      end
    end
  end
end
