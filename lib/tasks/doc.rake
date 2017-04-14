# frozen_string_literal: true
require 'yard'

namespace :doc do
  desc 'start a gem server'
  task :server do
    sh 'bundle exec yard server --gems'
  end

  desc 'use Graphviz to generate dot graph'
  task :graph do
    output_file = 'doc/erd.dot'
    sh "bundle exec yard graph --protected --full --dependencies > #{output_file}"
    puts 'open doc/erd.dot if you have graphviz installed'
  end

  YARD::Rake::YardocTask.new(:stats) do |t|
    t.stats_options = ['--list-undoc']
  end

  DOC_PATH = File.join('doc')
  YARD::Rake::YardocTask.new(:pages) do |t|
    t.options = ['-o', DOC_PATH]
  end
end
task doc: ['doc:pages']
