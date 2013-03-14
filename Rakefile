#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rake/testtask"

desc 'Run tests'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Benchmark'
task :bench do
  load 'bench/perf.rb' 
end

task :default => :test
