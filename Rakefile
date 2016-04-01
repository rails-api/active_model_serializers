begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'simplecov'
rescue LoadError
end

Bundler::GemHelper.install_tasks

require 'yard'

namespace :yard do
  YARD::Rake::YardocTask.new(:doc) do |t|
    t.stats_options = ['--list-undoc']
  end

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
end

begin
  require 'rubocop'
  require 'rubocop/rake_task'
rescue LoadError
else
  Rake::Task[:rubocop].clear if Rake::Task.task_defined?(:rubocop)
  require 'rbconfig'
  # https://github.com/bundler/bundler/blob/1b3eb2465a/lib/bundler/constants.rb#L2
  windows_platforms = /(msdos|mswin|djgpp|mingw)/
  if RbConfig::CONFIG['host_os'] =~ windows_platforms
    desc 'No-op rubocop on Windows-- unsupported platform'
    task :rubocop do
      puts 'Skipping rubocop on Windows'
    end
  elsif defined?(::Rubinius)
    desc 'No-op rubocop to avoid rbx segfault'
    task :rubocop do
      puts 'Skipping rubocop on rbx due to segfault'
      puts 'https://github.com/rubinius/rubinius/issues/3499'
    end
  else
    Rake::Task[:rubocop].clear if Rake::Task.task_defined?(:rubocop)
    desc 'Execute rubocop'
    RuboCop::RakeTask.new(:rubocop) do |task|
      task.options = ['--rails', '--display-cop-names', '--display-style-guide']
      task.fail_on_error = true
    end
  end
end

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.ruby_opts = ['-r./test/test_helper.rb']
  t.ruby_opts << ' -w' unless ENV['NO_WARN'] == 'true'
  t.verbose = true
end

desc 'Run isolated tests'
task isolated: ['test:isolated']
namespace :test do
  task :isolated do
    desc 'Run isolated tests for Railtie'
    require 'shellwords'
    dir = File.dirname(__FILE__)
    dir = Shellwords.shellescape(dir)
    isolated_test_files = FileList['test/**/*_test_isolated.rb']
    # https://github.com/rails/rails/blob/3d590add45/railties/lib/rails/generators/app_base.rb#L345-L363
    _bundle_command = Gem.bin_path('bundler', 'bundle')
    require 'bundler'
    Bundler.with_clean_env do
      isolated_test_files.all? do |test_file|
        command = "-w -I#{dir}/lib -I#{dir}/test #{Shellwords.shellescape(test_file)}"
        full_command = %("#{Gem.ruby}" #{command})
        system(full_command)
      end or fail 'Failures' # rubocop:disable Style/AndOr
    end
  end
end

if ENV['RAILS_VERSION'].to_s > '4.0' && RUBY_ENGINE == 'ruby'
  task default: [:isolated, :test, :rubocop]
else
  task default: [:test, :rubocop]
end

desc 'CI test task'
task :ci => [:default]
