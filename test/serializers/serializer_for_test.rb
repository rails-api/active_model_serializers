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

        def test_serializer_for_array
          serializer = ActiveModel::Serializer.serializer_for(@array)
          assert_equal ActiveModelSerializers.config.collection_serializer, serializer
        end

        def test_overwritten_serializer_for_array
          new_collection_serializer = Class.new
          ActiveModelSerializers.config.collection_serializer = new_collection_serializer
          serializer = ActiveModel::Serializer.serializer_for(@array)
          assert_equal new_collection_serializer, serializer
        end
      end

      class SerializerNotFoundTest < ActiveSupport::TestCase
        class Poro; end
        class Post < ActiveRecord::Base; end
        class PostSerializer < ActiveModel::Serializer; end
        class Comment < ActiveRecord::Base; end

        class C  < ::Model; end
        class CSerializer < ActiveModel::Serializer; end
        class B < C; end
        class A < B; end

        def setup
          @previous_serializer_not_found_policy = ActiveModelSerializers.config.on_serializer_not_found
          ActiveModelSerializers.config.on_serializer_not_found = -> (klass) { fail NameError, "Serializer for [#{klass}] not found" }
        end

        def teardown
          ActiveModelSerializers.config.on_serializer_not_found = @previous_serializer_not_found_policy
        end

        test 'serializer not found doesnt affect POROs' do
          assert_nothing_raised do
            ActiveModel::Serializer.serializer_for(Poro.new)
          end
        end

        test 'serializer not found triggers configured policy' do
          err = assert_raises(NameError) { ActiveModel::Serializer.serializer_for(Comment.new) }
          assert_equal(err.message, 'Serializer for [ActiveModel::Serializer::SerializerForTest::SerializerNotFoundTest::Comment] not found')
        end

        test 'serializer not found doesnt trigger on valid model' do
          assert_nothing_raised NameError do
            ActiveModel::Serializer.serializer_for(Post.new)
          end
        end

        test 'serializer not found goes to the bottom of the class hierarchy' do
          assert_equal(ActiveModel::Serializer.serializer_for(C.new), CSerializer)
          assert_equal(ActiveModel::Serializer.serializer_for(B.new), CSerializer)
          assert_equal(ActiveModel::Serializer.serializer_for(A.new), CSerializer)
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

        def test_serializer_for_non_ams_serializer
          serializer = ActiveModel::Serializer.serializer_for(@tweet)
          assert_equal nil, serializer
        end

        def test_serializer_for_existing_serializer
          serializer = ActiveModel::Serializer.serializer_for(@profile)
          assert_equal ProfileSerializer, serializer
        end

        def test_serializer_for_existing_serializer_with_lookup_disabled
          serializer = with_serializer_lookup_disabled do
            ActiveModel::Serializer.serializer_for(@profile)
          end
          assert_equal nil, serializer
        end

        def test_serializer_for_not_existing_serializer
          serializer = ActiveModel::Serializer.serializer_for(@model)
          assert_equal nil, serializer
        end

        def test_serializer_inherited_serializer
          serializer = ActiveModel::Serializer.serializer_for(@my_profile)
          assert_equal ProfileSerializer, serializer
        end

        def test_serializer_inherited_serializer_with_lookup_disabled
          serializer = with_serializer_lookup_disabled do
            ActiveModel::Serializer.serializer_for(@my_profile)
          end
          assert_equal nil, serializer
        end

        def test_serializer_custom_serializer
          serializer = ActiveModel::Serializer.serializer_for(@custom_profile)
          assert_equal ProfileSerializer, serializer
        end

        def test_serializer_custom_serializer_with_lookup_disabled
          serializer = with_serializer_lookup_disabled do
            ActiveModel::Serializer.serializer_for(@custom_profile)
          end
          assert_equal ProfileSerializer, serializer
        end

        def test_serializer_for_namespaced_resource
          post = ResourceNamespace::Post.new
          serializer = ActiveModel::Serializer.serializer_for(post)
          assert_equal ResourceNamespace::PostSerializer, serializer
        end

        def test_serializer_for_namespaced_resource_with_lookup_disabled
          post = ResourceNamespace::Post.new
          serializer = with_serializer_lookup_disabled do
            ActiveModel::Serializer.serializer_for(post)
          end
          assert_equal nil, serializer
        end

        def test_serializer_for_nested_resource
          comment = ResourceNamespace::Comment.new
          serializer = ResourceNamespace::PostSerializer.serializer_for(comment)
          assert_equal ResourceNamespace::PostSerializer::CommentSerializer, serializer
        end

        def test_serializer_for_nested_resource_with_lookup_disabled
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
