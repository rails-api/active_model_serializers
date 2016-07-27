require 'test_helper'

module ActiveModel
  class Serializer
    class SerializerForTest < ActiveSupport::TestCase
      class CollectionSerializerTest < ActiveSupport::TestCase
        def setup
          @array = [1, 2, 3]
          @previous_collection_serializer = ActiveModelSerializers.config.collection_serializer
        end

        def teardown
          ActiveModelSerializers.config.collection_serializer = @previous_collection_serializer
        end

        test 'serializer_for_array' do
          serializer = ActiveModel::Serializer.serializer_for(@array)
          assert_equal ActiveModelSerializers.config.collection_serializer, serializer
        end

        test 'overwritten_serializer_for_array' do
          new_collection_serializer = Class.new
          ActiveModelSerializers.config.collection_serializer = new_collection_serializer
          serializer = ActiveModel::Serializer.serializer_for(@array)
          assert_equal new_collection_serializer, serializer
        end
      end

      class SerializerTest < ActiveSupport::TestCase
        module ResourceNamespace
          class Post    < ::Model; end
          class Comment < ::Model; end

          class PostSerializer < ActiveModel::Serializer
            class CommentSerializer < ActiveModel::Serializer
            end
          end
        end

        class MyProfile < Profile
        end

        class CustomProfile
          def serializer_class
            ProfileSerializer
          end
        end

        class Tweet < ::Model; end
        TweetSerializer = Class.new

        def setup
          @profile = Profile.new
          @my_profile = MyProfile.new
          @custom_profile = CustomProfile.new
          @model = ::Model.new
          @tweet = Tweet.new
        end

        test 'serializer_for_non_ams_serializer' do
          serializer = ActiveModel::Serializer.serializer_for(@tweet)
          assert_equal nil, serializer
        end

        test 'serializer_for_existing_serializer' do
          serializer = ActiveModel::Serializer.serializer_for(@profile)
          assert_equal ProfileSerializer, serializer
        end

        test 'serializer_for_existing_serializer_with_lookup_disabled' do
          serializer = with_serializer_lookup_disabled do
            ActiveModel::Serializer.serializer_for(@profile)
          end
          assert_equal nil, serializer
        end

        test 'serializer_for_not_existing_serializer' do
          serializer = ActiveModel::Serializer.serializer_for(@model)
          assert_equal nil, serializer
        end

        test 'serializer_inherited_serializer' do
          serializer = ActiveModel::Serializer.serializer_for(@my_profile)
          assert_equal ProfileSerializer, serializer
        end

        test 'serializer_inherited_serializer_with_lookup_disabled' do
          serializer = with_serializer_lookup_disabled do
            ActiveModel::Serializer.serializer_for(@my_profile)
          end
          assert_equal nil, serializer
        end

        test 'serializer_custom_serializer' do
          serializer = ActiveModel::Serializer.serializer_for(@custom_profile)
          assert_equal ProfileSerializer, serializer
        end

        test 'serializer_custom_serializer_with_lookup_disabled' do
          serializer = with_serializer_lookup_disabled do
            ActiveModel::Serializer.serializer_for(@custom_profile)
          end
          assert_equal ProfileSerializer, serializer
        end

        test 'serializer_for_namespaced_resource' do
          post = ResourceNamespace::Post.new
          serializer = ActiveModel::Serializer.serializer_for(post)
          assert_equal ResourceNamespace::PostSerializer, serializer
        end

        test 'serializer_for_namespaced_resource_with_lookup_disabled' do
          post = ResourceNamespace::Post.new
          serializer = with_serializer_lookup_disabled do
            ActiveModel::Serializer.serializer_for(post)
          end
          assert_equal nil, serializer
        end

        test 'serializer_for_nested_resource' do
          comment = ResourceNamespace::Comment.new
          serializer = ResourceNamespace::PostSerializer.serializer_for(comment)
          assert_equal ResourceNamespace::PostSerializer::CommentSerializer, serializer
        end

        test 'serializer_for_nested_resource_with_lookup_disabled' do
          comment = ResourceNamespace::Comment.new
          serializer = with_serializer_lookup_disabled do
            ResourceNamespace::PostSerializer.serializer_for(comment)
          end
          assert_equal nil, serializer
        end
      end
    end
  end
end
