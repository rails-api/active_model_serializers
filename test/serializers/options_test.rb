require 'test_helper'

module ActiveModel
  class Serializer
    class OptionsTest < ActiveSupport::TestCase
      def setup
        @profile = Profile.new(name: 'Name 1', description: 'Description 1')
      end

      def test_options_are_accessible
        @profile_serializer = ProfileSerializer.new(@profile, my_options: :accessible)
        assert @profile_serializer.arguments_passed_in?
      end

      def test_no_option_is_passed_in
        @profile_serializer = ProfileSerializer.new(@profile)
        refute @profile_serializer.arguments_passed_in?
      end
    end
  end
end
