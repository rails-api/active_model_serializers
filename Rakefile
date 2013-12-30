#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rake/testtask"

desc 'Run tests'
test_task = Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

task default: :test

desc 'Run tests in isolated processes'
namespace :test do
  task :isolated do
    Dir[test_task.pattern].each do |file|
      cmd = ['ruby']
      test_task.libs.each { |l| cmd << '-I' << l }
      cmd << file
      sh cmd.join(' ')
    end
  end
end
