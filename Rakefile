require 'bundler/gem_tasks'
require 'git'
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
  @git = Git.init('.')
  ref  = @git.current_branch

  actual = run_benchmark_spec ref
  master = run_benchmark_spec 'master'

  @git.checkout(ref)

  puts "\n\nResults ============================\n"
  puts "------------------------------------~> (Branch) MASTER"
  puts master
  puts "------------------------------------\n\n"

  puts "------------------------------------~> (Actual Branch) #{ref}"
  puts actual
  puts "------------------------------------"
end

def run_benchmark_spec(ref)
    @git.checkout(ref)
    response = Benchmark.realtime { Rake::Task['benchmark_tests'].invoke }
    Rake::Task['benchmark_tests'].reenable
    response
end