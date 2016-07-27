require 'test_helper'

module ActiveModel
  class Serializer
    class OptionsTest < ActiveSupport::TestCase
      def setup
        @profile = Profile.new(name: 'Name 1', description: 'Description 1')
      end

      test 'options_are_accessible' do
        @profile_serializer = ProfileSerializer.new(@profile, my_options: :accessible)
        assert @profile_serializer.arguments_passed_in?
      end

      test 'no_option_is_passed_in' do
        @profile_serializer = ProfileSerializer.new(@profile)
        refute @profile_serializer.arguments_passed_in?
      end
    end
  end
end
