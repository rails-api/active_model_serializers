# frozen_string_literal: true
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.ruby_opts = ['-r./test/test_helper.rb']
  t.ruby_opts << ' -w' unless ENV['NO_WARN'] == 'true'
  t.verbose = true
end
