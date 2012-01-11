require "test_helper"

class SerializerTest < ActiveModel::TestCase
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

  def test_include_associations
    post = Model.new(:title => "New Post", :body => "Body")
    comment = Model.new(:id => 1, :body => "ZOMG A COMMENT")
    post.comments = [ comment ]

    comment_serializer_class = def_serializer do
      attributes :body
    end

    post_serializer_class = def_serializer do
      attributes :title, :body
    end

    post_serializer = post_serializer_class.new(post, nil)

    hash = {}
    root_hash = {}
    post_serializer.include! :comments,
      :embed => :ids,
      :include => true,
      :hash => root_hash,
      :node => hash,
      :value => post.comments,
      :serializer => comment_serializer_class

    assert_equal({
      :comments => [ 1 ]
    }, hash)

    assert_equal({
      :comments => [
        { :body => "ZOMG A COMMENT" }
      ]
    }, root_hash)
  end
end
