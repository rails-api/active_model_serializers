require 'bundler/gem_tasks'
require 'rugged'
require 'benchmark'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.ruby_opts = ['-r./test/test_helper.rb']
  t.verbose = true
end

Rake::TestTask.new :benchmark_tests do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_benchmark.rb']
  t.ruby_opts = ['-r./test/test_helper.rb']
  t.verbose = true
end

task :benchmark do
  @repo = Rugged::Repository.new('.')
  ref   = @repo.head

  actual_branch = ref.name

  set_commit('master')
  old_bench = Benchmark.realtime { Rake::Task['benchmark_tests'].execute }

  set_commit(actual_branch)
  new_bench = Benchmark.realtime { Rake::Task['benchmark_tests'].execute }

  puts 'Results ============================'
  puts "------------------------------------~> (Branch) MASTER"
  puts old_bench
  puts "------------------------------------"

  puts "------------------------------------~> (Actual Branch) #{actual_branch}"
  puts new_bench
  puts "------------------------------------"
end

def set_commit(ref)
  @repo.checkout ref
end