require_relative './benchmarking_support'
require_relative './app'
require_relative './setup'

time = 10
disable_gc = true



authors_query = Author.preload(:posts).preload(:profile)
author = authors_query.first
authors = authors_query.to_a


Benchmark.ams('Single: DefaultSerializer', time: time, disable_gc: disable_gc) do
 ActiveModel::DefaultSerializer.new(author).to_json
end

Benchmark.ams('ArraySerializer', time: time, disable_gc: disable_gc) do
 ActiveModel::ArraySerializer.new(authors).to_json
end

Benchmark.ams('ArraySerializer: each_serializer: DefaultSerializer', time: time, disable_gc: disable_gc) do
 ActiveModel::ArraySerializer.new(authors, each_serializer:ActiveModel::DefaultSerializer).to_json
end

Benchmark.ams('FlatAuthorSerializer', time: time, disable_gc: disable_gc) do
 FlatAuthorSerializer.new(author).to_json
end

Benchmark.ams('ArraySerializer: each_serializer: FlatAuthorSerializer', time: time, disable_gc: disable_gc) do
 ActiveModel::ArraySerializer.new(authors, each_serializer: FlatAuthorSerializer).to_json
end

Benchmark.ams('AuthorWithDefaultRelationshipsSerializer', time: time, disable_gc: disable_gc) do
 AuthorWithDefaultRelationshipsSerializer.new(author).to_json
end

Benchmark.ams('ArraySerializer: each_serializer: AuthorWithDefaultRelationshipsSerializer', time: time, disable_gc: disable_gc) do
 ActiveModel::ArraySerializer.new(authors, each_serializer: AuthorWithDefaultRelationshipsSerializer).to_json
end
