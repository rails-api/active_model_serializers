require 'test_helper'

module ActiveModel
  class Serializer
    class OptionsTest < ActiveModel::TestCase
      def setup
        @profile = Profile.new({ name: 'Name 1', description: 'Description 1', comments: 'Comments 1' })
      end

      def test_meta
        profile_serializer = ProfileSerializer.new(@profile, root: 'profile', random_option: "This is an option")

        assert_equal("This is an option", profile_serializer.options[:random_option])
      end
    end
  end
end
