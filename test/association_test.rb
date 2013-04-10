require "test_helper"

class AssociationTest < ActiveModel::TestCase
  def def_serializer(&block)
    Class.new(ActiveModel::Serializer, &block)
  end

  class Model
    def initialize(hash={})
      @attributes = hash
    end

    def read_attribute_for_serialization(name)
      @attributes[name]
    end

    def as_json(*)
      { :model => "Model" }
    end

    def method_missing(meth, *args)
      if meth.to_s =~ /^(.*)=$/
        @attributes[$1.to_sym] = args[0]
      elsif @attributes.key?(meth)
        @attributes[meth]
      else
        super
      end
    end
  end

  def setup
    @hash = {}
    @root_hash = {}

    @post = Model.new(:title => "New Post", :body => "Body")
    @comment = Model.new(:id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT")
    @post.comments = [ @comment ]
    @post.comment = @comment

    @comment_serializer_class = def_serializer do
      attributes :id, :external_id, :body
    end

    @post_serializer_class = def_serializer do
      attributes :title, :body
    end

    @post_serializer = @post_serializer_class.new(@post, :hash => @root_hash)
  end

  def include!(key, options={})
    @post_serializer.include! key, {
      :embed => :ids,
      :include => true,
      :node => @hash,
      :serializer => @comment_serializer_class
    }.merge(options)
  end

  def include_bare!(key, options={})
    @post_serializer.include! key, {
      :node => @hash,
      :serializer => @comment_serializer_class
    }.merge(options)
  end

  class NoDefaults < AssociationTest
    def test_include_bang_has_many_associations
      include! :comments, :value => @post.comments

      assert_equal({
        :comment_ids => [ 1 ]
      }, @hash)

      assert_equal({
        :comments => [
          { :id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT" }
        ]
      }, @root_hash)
    end

    def test_include_bang_with_embed_false
      include! :comments, :value => @post.comments, :embed => false

      assert_equal({}, @hash)
      assert_equal({}, @root_hash)
    end

    def test_include_bang_with_embed_ids_include_false
      include! :comments, :value => @post.comments, :embed => :ids, :include => false

      assert_equal({
        :comment_ids => [ 1 ]
      }, @hash)

      assert_equal({}, @root_hash)
    end

    def test_include_bang_has_one_associations
      include! :comment, :value => @post.comment

      assert_equal({
        :comment_id => 1
      }, @hash)

      assert_equal({
        :comments => [{ :id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT" }]
      }, @root_hash)
    end
  end

  class DefaultsTest < AssociationTest
    def test_with_default_has_many
      @post_serializer_class.class_eval do
        has_many :comments
      end

      include! :comments

      assert_equal({
        :comment_ids => [ 1 ]
      }, @hash)

      assert_equal({
        :comments => [
          { :id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT" }
        ]
      }, @root_hash)
    end

    def test_with_default_has_one
      @post_serializer_class.class_eval do
        has_one :comment
      end

      include! :comment

      assert_equal({
        :comment_id => 1
      }, @hash)

      assert_equal({
        :comments => [
          { :id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT" }
        ]
      }, @root_hash)
    end

    def test_with_default_has_many_with_custom_key
      @post_serializer_class.class_eval do
        has_many :comments, :key => :custom_comments
      end

      include! :comments

      assert_equal({
        :custom_comments => [ 1 ]
      }, @hash)

      assert_equal({
        :comments => [
          { :id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT" }
        ]
      }, @root_hash)
    end

    def test_with_default_has_one_with_custom_key
      @post_serializer_class.class_eval do
        has_one :comment, :key => :custom_comment_id
      end

      include! :comment

      assert_equal({
        :custom_comment_id => 1
      }, @hash)

      assert_equal({
        :comments => [
          { :id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT" }
        ]
      }, @root_hash)
    end

    def test_with_default_has_many_with_custom_embed_key
      @post_serializer_class.class_eval do
        has_many :comments, :embed_key => :external_id
      end

      include! :comments

      assert_equal({
        :comment_ids => [ "COMM001" ]
      }, @hash)

      assert_equal({
        :comments => [
          { :id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT" }
        ]
      }, @root_hash)
    end

    def test_with_default_has_one_with_custom_embed_key
      @post_serializer_class.class_eval do
        has_one :comment, :embed_key => :external_id
      end

      include! :comment

      assert_equal({
        :comment_id => "COMM001"
      }, @hash)

      assert_equal({
        :comments => [
          { :id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT" }
        ]
      }, @root_hash)
    end

    def test_with_default_has_many_with_custom_key_and_custom_embed_key
      @post_serializer_class.class_eval do
        has_many :comments, :key => :custom_comments, :embed_key => :external_id
      end

      include! :comments

      assert_equal({
        :custom_comments => [ "COMM001" ]
      }, @hash)

      assert_equal({
        :comments => [
          { :id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT" }
        ]
      }, @root_hash)
    end

    def test_with_default_has_one_with_custom_key_and_custom_embed_key
      @post_serializer_class.class_eval do
        has_one :comment, :key => :custom_comment, :embed_key => :external_id
      end

      include! :comment

      assert_equal({
        :custom_comment => "COMM001"
      }, @hash)

      assert_equal({
        :comments => [
          { :id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT" }
        ]
      }, @root_hash)
    end

    def test_embed_objects_for_has_many_associations
      @post_serializer_class.class_eval do
        has_many :comments, :embed => :objects
      end

      include_bare! :comments

      assert_equal({
        :comments => [
          { :id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT" }
        ]
      }, @hash)

      assert_equal({}, @root_hash)
    end

    def test_embed_ids_for_has_many_associations
      @post_serializer_class.class_eval do
        has_many :comments, :embed => :ids
      end

      include_bare! :comments

      assert_equal({
        :comment_ids => [ 1 ]
      }, @hash)

      assert_equal({}, @root_hash)
    end

    def test_embed_false_for_has_many_associations
      @post_serializer_class.class_eval do
        has_many :comments, :embed => false
      end

      include_bare! :comments

      assert_equal({}, @hash)
      assert_equal({}, @root_hash)
    end

    def test_embed_ids_include_true_for_has_many_associations
      @post_serializer_class.class_eval do
        has_many :comments, :embed => :ids, :include => true
      end

      include_bare! :comments

      assert_equal({
        :comment_ids => [ 1 ]
      }, @hash)

      assert_equal({
        :comments => [
          { :id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT" }
        ]
      }, @root_hash)
    end

    def test_embed_ids_for_has_one_associations
      @post_serializer_class.class_eval do
        has_one :comment, :embed => :ids
      end

      include_bare! :comment

      assert_equal({
        :comment_id => 1
      }, @hash)

      assert_equal({}, @root_hash)
    end

    def test_embed_false_for_has_one_associations
      @post_serializer_class.class_eval do
        has_one :comment, :embed => false
      end

      include_bare! :comment

      assert_equal({}, @hash)
      assert_equal({}, @root_hash)
    end

    def test_embed_ids_include_true_for_has_one_associations
      @post_serializer_class.class_eval do
        has_one :comment, :embed => :ids, :include => true
      end

      include_bare! :comment

      assert_equal({
        :comment_id => 1
      }, @hash)

      assert_equal({
        :comments => [
          { :id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT" }
        ]
      }, @root_hash)
    end

    def test_embed_ids_include_true_does_not_serialize_multiple_times
      @post.recent_comment = @comment

      @post_serializer_class.class_eval do
        has_one :comment, :embed => :ids, :include => true
        has_one :recent_comment, :embed => :ids, :include => true, :root => :comments
      end

      # Count how often the @comment record is serialized.
      serialized_times = 0
      @comment.class_eval do
        define_method :read_attribute_for_serialization, lambda { |name|
          serialized_times += 1 if name == :body
          super(name)
        }
      end

      include_bare! :comment
      include_bare! :recent_comment

      assert_equal 1, serialized_times
    end

    def test_include_with_read_association_id_for_serialization_hook
      @post_serializer_class.class_eval do
        has_one :comment, :embed => :ids, :include => true
      end

      association_name = nil
      @post.class_eval do
        define_method :read_attribute_for_serialization, lambda { |name|
          association_name = name
          send(name)
        }
        define_method :comment_id, lambda {
          @attributes[:comment].id
        }
      end

      include_bare! :comment

      assert_equal({
        :comment_id => 1
      }, @hash)
    end

    def test_include_with_read_association_ids_for_serialization_hook
      @post_serializer_class.class_eval do
        has_many :comments, :embed => :ids, :include => false
      end

      association_name = nil
      @post.class_eval do
        define_method :read_attribute_for_serialization, lambda { |name|
          association_name = name
          send(name)
        }
        define_method :comment_ids, lambda {
          @attributes[:comments].map(&:id)
        }
      end

      include_bare! :comments

      assert_equal({
        :comment_ids => [1]
      }, @hash)
    end
  end

  class RecursiveTest < AssociationTest
    class BarSerializer < ActiveModel::Serializer; end

    class FooSerializer < ActiveModel::Serializer
      root :foos
      attributes :id
      has_many :bars, :serializer => BarSerializer, :root => :bars, :embed => :ids, :include => true
    end

    class BarSerializer < ActiveModel::Serializer
      root :bars
      attributes :id
      has_many :foos, :serializer => FooSerializer, :root => :foos, :embed => :ids, :include => true
    end

    class Foo < Model
      def active_model_serializer; FooSerializer; end
    end

    class Bar < Model
      def active_model_serializer; BarSerializer; end
    end

    def setup
      super

      foo = Foo.new(:id => 1)
      bar = Bar.new(:id => 2)

      foo.bars = [ bar ]
      bar.foos = [ foo ]

      collection = [ foo ]

      @serializer = collection.active_model_serializer.new(collection, :root => :foos)
    end

    def test_mutual_relation_result
      assert_equal({
        :foos => [{
          :bar_ids => [ 2 ],
          :id => 1
        }],
        :bars => [{
          :foo_ids => [ 1 ],
          :id => 2
        }]
      }, @serializer.as_json)
    end

    def test_mutual_relation_does_not_raise_error
      assert_nothing_raised SystemStackError, 'stack level too deep' do
        @serializer.as_json
      end
    end
  end

  class InclusionTest < AssociationTest
    def setup
      super

      comment_serializer_class = @comment_serializer_class

      @post_serializer_class.class_eval do
        root :post
        embed :ids, :include => true
        has_many :comments, :serializer => comment_serializer_class
      end
    end

    def test_when_it_is_included
      post_serializer = @post_serializer_class.new(
        @post, :include => [:comments]
      )

      json = post_serializer.as_json

      assert_equal({
        :post => {
          :title => "New Post",
          :body => "Body",
          :comment_ids => [ 1 ]
        },
        :comments => [
          { :id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT" }
        ]
      }, json)
    end

    def test_when_it_is_not_included
      post_serializer = @post_serializer_class.new(
        @post, :include => []
      )

      json = post_serializer.as_json

      assert_equal({
        :post => {
          :title => "New Post",
          :body => "Body",
          :comment_ids => [ 1 ]
        }
      }, json)
    end

    def test_when_it_is_excluded
      post_serializer = @post_serializer_class.new(
        @post, :exclude => [:comments]
      )

      json = post_serializer.as_json

      assert_equal({
        :post => {
          :title => "New Post",
          :body => "Body",
          :comment_ids => [ 1 ]
        }
      }, json)
    end

    def test_when_it_is_not_excluded
      post_serializer = @post_serializer_class.new(
        @post, :exclude => []
      )

      json = post_serializer.as_json

      assert_equal({
        :post => {
          :title => "New Post",
          :body => "Body",
          :comment_ids => [ 1 ]
        },
        :comments => [
          { :id => 1, :external_id => "COMM001", :body => "ZOMG A COMMENT" }
        ]
      }, json)
    end
  end

  class StringSerializerOption < AssociationTest
    class StringSerializer < ActiveModel::Serializer
      attributes :id, :body
    end

    def test_specifying_serializer_class_as_string
      @post_serializer_class.class_eval do
        has_many :comments, :embed => :objects
      end

      include_bare! :comments, :serializer => "AssociationTest::StringSerializerOption::StringSerializer"

      assert_equal({
        :comments => [
          { :id => 1, :body => "ZOMG A COMMENT" }
        ]
      }, @hash)

      assert_equal({}, @root_hash)
    end
  end
end
