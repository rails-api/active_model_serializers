require 'test_helper'
module ActiveModel
  class Serializer
    class ReflectionTest < ActiveSupport::TestCase
      class Blog < ActiveModelSerializers::Model
        attributes :id
      end
      class BlogSerializer < ActiveModel::Serializer
        type 'blog'
        attributes :id
      end

      setup do
        @expected_meta = { id: 1 }
        @expected_links = { self: 'no_uri_validation' }
        @empty_links = {}
        model_attributes = { blog: Blog.new(@expected_meta) }
        @model = Class.new(ActiveModelSerializers::Model) do
          attributes(*model_attributes.keys)

          def self.name
            'TestModel'
          end
        end.new(model_attributes)
        @instance_options = {}
      end

      def test_reflection_block_with_link_mutates_the_reflection_links
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            link :self, 'no_uri_validation'
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)
        assert_equal @empty_links, reflection.instance_variable_get(:@_links)

        # Build Association
        association = reflection.build_association(serializer_instance, @instance_options)
        assert_equal @expected_links, association.links
        assert_equal @expected_links, reflection.instance_variable_get(:@_links)
      end

      def test_reflection_block_with_link_block_mutates_the_reflection_links
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            link :self do
              'no_uri_validation'
            end
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)
        assert_equal @empty_links, reflection.instance_variable_get(:@_links)

        # Build Association
        association = reflection.build_association(serializer_instance, @instance_options)
        # Assert before instance_eval link
        link = association.links.fetch(:self)
        assert_respond_to link, :call

        # Assert after instance_eval link
        assert_equal @expected_links.fetch(:self), reflection.instance_eval(&link)
        assert_respond_to reflection.instance_variable_get(:@_links).fetch(:self), :call
      end

      def test_reflection_block_with_meta_mutates_the_reflection_meta
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            meta(id: object.blog.id)
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)
        assert_nil reflection.instance_variable_get(:@_meta)

        # Build Association
        association = reflection.build_association(serializer_instance, @instance_options)
        assert_equal @expected_meta, association.meta
        assert_equal @expected_meta, reflection.instance_variable_get(:@_meta)
      end

      def test_reflection_block_with_meta_block_mutates_the_reflection_meta
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            meta do
              { id: object.blog.id }
            end
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)
        assert_nil reflection.instance_variable_get(:@_meta)

        # Build Association
        association = reflection.build_association(serializer_instance, @instance_options)
        # Assert before instance_eval meta
        assert_respond_to association.meta, :call
        assert_respond_to reflection.instance_variable_get(:@_meta), :call

        # Assert after instance_eval meta
        assert_equal @expected_meta, reflection.instance_eval(&association.meta)
        assert_respond_to reflection.instance_variable_get(:@_meta), :call
        assert_respond_to association.meta, :call
      end

      def test_reflection_block_with_meta_in_link_block_mutates_the_reflection_meta
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            link :self do
              meta(id: object.blog.id)
              'no_uri_validation'
            end
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)
        assert_nil reflection.instance_variable_get(:@_meta)
        assert_equal @empty_links, reflection.instance_variable_get(:@_links)

        # Build Association
        association = reflection.build_association(serializer_instance, @instance_options)
        # Assert before instance_eval link meta
        assert_nil association.meta
        assert_nil reflection.instance_variable_get(:@_meta)

        link = association.links.fetch(:self)
        assert_respond_to link, :call
        assert_respond_to reflection.instance_variable_get(:@_links).fetch(:self), :call
        assert_nil reflection.instance_variable_get(:@_meta)

        # Assert after instance_eval link
        assert_equal 'no_uri_validation', reflection.instance_eval(&link)
        assert_equal @expected_meta, reflection.instance_variable_get(:@_meta)
        assert_nil association.meta
      end

      # rubocop:disable Metrics/AbcSize
      def test_reflection_block_with_meta_block_in_link_block_mutates_the_reflection_meta
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            link :self do
              meta do
                { id: object.blog.id }
              end
              'no_uri_validation'
            end
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)
        assert_nil reflection.instance_variable_get(:@_meta)

        # Build Association
        association = reflection.build_association(serializer_instance, @instance_options)
        assert_nil association.meta
        assert_nil reflection.instance_variable_get(:@_meta)

        # Assert before instance_eval link
        link = association.links.fetch(:self)
        assert_nil reflection.instance_variable_get(:@_meta)
        assert_respond_to link, :call
        assert_respond_to association.links.fetch(:self), :call

        # Assert after instance_eval link
        assert_equal 'no_uri_validation', reflection.instance_eval(&link)
        assert_respond_to association.links.fetch(:self), :call
        # Assert before instance_eval link meta
        assert_respond_to reflection.instance_variable_get(:@_meta), :call
        assert_nil association.meta

        # Assert after instance_eval link meta
        assert_equal @expected_meta, reflection.instance_eval(&reflection.instance_variable_get(:@_meta))
        assert_nil association.meta
      end
      # rubocop:enable Metrics/AbcSize

      def test_no_href_in_vanilla_reflection
        serializer_class = Class.new(ActiveModel::Serializer) do
          has_one :blog do
            link :self do
              href 'no_uri_validation'
            end
          end
        end
        serializer_instance = serializer_class.new(@model, @instance_options)

        # Get Reflection
        reflection = serializer_class._reflections.fetch(:blog)
        assert_equal @empty_links, reflection.instance_variable_get(:@_links)

        # Build Association
        association = reflection.build_association(serializer_instance, @instance_options)
        # Assert before instance_eval link
        link = association.links.fetch(:self)
        assert_respond_to link, :call

        # Assert after instance_eval link
        exception = assert_raise(NoMethodError) do
          reflection.instance_eval(&link)
        end
        assert_match(/undefined method `href'/, exception.message)
      end
    end
  end
end
