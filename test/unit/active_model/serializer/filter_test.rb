require 'test_helper'

module ActiveModel
  class Serializer
    class FilterAttributesTest < ActiveModel::TestCase
      def setup
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
        @profile_serializer = ProfileSerializer.new(@profile)
        @profile_serializer.instance_eval do
          def filter_attributes(keys)
            keys - [:description]
          end
        end
      end

      def test_filtered_attributes_serialization
        assert_equal({
          'profile' => { name: 'Name 1' }
        }, @profile_serializer.as_json)
      end
    end

    class FilterAssociationsTest < ActiveModel::TestCase
      def setup
        @association = PostSerializer._associations[:comments]
        @old_association = @association.dup
        @association.embed = :ids
        @association.embed_in_root = true
        @post = Post.new({ title: 'Title 1', body: 'Body 1', date: '1/1/2000' })
        @post_serializer = PostSerializer.new(@post)
        @post_serializer.instance_eval do
          def filter_attributes(keys)
            keys & [:title]
          end
          
          def filter_associations(keys)
            keys - [:comments]
          end
        end
      end

      def teardown
        PostSerializer._associations[:comments] = @old_association
      end

      def test_filtered_associations_serialization
        assert_equal({
          'post' => { title: 'Title 1' }
        }, @post_serializer.as_json)
      end

      def test_filter_associations_and_filter_attributes
        @post_serializer.instance_eval do
          
          def filter_attributes(keys)
            keys & [:title]
          end
          
          def filter_associations(keys) 
            keys 
          end
        end

        assert_equal({
          title: 'Title 1', 'comment_ids' => @post.comments.map { |c| c.object_id }
        }, @post_serializer.serializable_hash)

      end
    end

  end
end
