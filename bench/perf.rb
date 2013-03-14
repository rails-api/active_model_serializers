require "rubygems"
require "bundler/setup"
require "active_model_serializers"
require "active_support/json"
require "benchmark"

class User < Struct.new(:id,:name,:age,:about) 
  include ActiveModel::SerializerSupport
  
  def fast_hash
    h = { 
      id: read_attribute_for_serialization(:id), 
      name: read_attribute_for_serialization(:name), 
      about: read_attribute_for_serialization(:about)
    }
    h[:age] = read_attribute_for_serialization(:age) if age > 18
    h
  end
end

class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :age, :about

  def include_age?
    object.age > 18
  end
end



u = User.new(1, "sam", 10, "about")
s = UserSerializer.new(u)

u2 = User.new(2, "sam", 20, "about")
s2 = UserSerializer.new(u2)

p s2.fast_attributes
p s2.attributes

p s.fast_attributes
p s.attributes


n = 100000

Benchmark.bmbm {|x| 
  x.report("init") { n.times { UserSerializer.new(u) } }
  x.report("fast_hash") { n.times { u.fast_hash } }
  x.report("fast_attributes") { n.times { UserSerializer.new(u).fast_attributes } } 
  x.report("fast_serializable_hash") { n.times { UserSerializer.new(u).fast_serializable_hash } }
  x.report("attributes") { n.times { UserSerializer.new(u).attributes } } 
  x.report("serializable_hash") { n.times { UserSerializer.new(u).serializable_hash } }
  x.report("serializable_hash_with_instrumentation") { n.times { UserSerializer.new(u).serializable_hash_with_instrumentation } }
}   


