#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
Bundler.setup

require 'active_model_serializers'
require 'active_support/all'
require 'benchmark/ips'
require_relative './../test/fixtures/poro'

def bench_adapters(resource)
  serializer = PostWithCustomKeysSerializer.new(resource)

  Benchmark.ips do |x|
    ActiveModel::Serializer::Adapter.adapter_map.each do |adapter_name, adapter_class|
      x.report(adapter_name) { adapter_class.new(serializer).to_json } unless adapter_name == 'null'
    end

    x.compare!
  end
end

def bench_with_associations
  post = Post.new(id: 1, title: 'New Post', body: 'Body')
  author = Author.new(id: 1, name: 'Ian K')
  first_comment = Comment.new(id: 1, body: 'ZOMG A COMMENT')
  second_comment = Comment.new(id: 2, body: 'ZOMG ANOTHER COMMENT')
  post.comments = [first_comment, second_comment]
  first_comment.post = post
  second_comment.post = post
  post.author = author
  blog = Blog.new(id: 1, name: 'My Blog!!')
  post.blog = blog

  bench_adapters(post)
end

def bench_without_associations
  post = Post.new(id: 1, title: 'New Post', body: 'Body')
  bench_adapters(post)
end

puts '=== Benchmarking resource with associations ======'
puts
bench_with_associations
puts

puts '=== Benchmarking resource without associations ==='
puts
bench_without_associations
puts
