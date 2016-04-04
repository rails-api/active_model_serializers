require_relative './benchmarking_support'
require_relative './app'

time = 10
disable_gc = true
ActiveModelSerializers.config.key_transform = :unaltered
comments = (0..50).map do |i|
  Comment.new(id: i, body: 'ZOMG A COMMENT')
end
author = Author.new(id: 42, first_name: 'Joao', last_name: 'Moura')
post = Post.new(id: 1337, title: 'New Post', blog: nil, body: 'Body', comments: comments, author: author)
serializer = PostSerializer.new(post)
adapter = ActiveModelSerializers::Adapter::JsonApi.new(serializer)
serialization = adapter.as_json

Benchmark.ams('camel', time: time, disable_gc: disable_gc) do
  ActiveModelSerializers::KeyTransform.camel(serialization)
end

Benchmark.ams('camel_lower', time: time, disable_gc: disable_gc) do
  ActiveModelSerializers::KeyTransform.camel_lower(serialization)
end

Benchmark.ams('dash', time: time, disable_gc: disable_gc) do
  ActiveModelSerializers::KeyTransform.dash(serialization)
end

Benchmark.ams('unaltered', time: time, disable_gc: disable_gc) do
  ActiveModelSerializers::KeyTransform.unaltered(serialization)
end

Benchmark.ams('underscore', time: time, disable_gc: disable_gc) do
  ActiveModelSerializers::KeyTransform.underscore(serialization)
end
