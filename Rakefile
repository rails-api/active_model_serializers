begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'simplecov'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end
import('lib/tasks/rubocop.rake')

Bundler::GemHelper.install_tasks

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

  # #files => Array<String>
  # The Ruby source files (and any extra documentation files separated by '-') to process.
  DOC_FILES = ['lib/**/*.rb', '-', 'README.md']
  DOC_FILES.concat Rake::FileList['docs/**/*.md'].to_a
  DOC_FILES.freeze
  DOC_REF = `git log --pretty=format:'%h' -1 | less -F -X`.chomp
  DOC_VERSION = ActiveModel::Serializer::VERSION
  DOC_REMOTE = "git@github.com:rails-api/active_model_serializers.git"
  DOC_REMOTE_NAME = 'origin'
  DOC_ROOT = File.expand_path('..', __FILE__)
  DOC_PATH = File.join('..', 'ams.doc')
  DOC_DIR  = File.join(DOC_ROOT, DOC_PATH)

  YARD::Rake::YardocTask.new(:doc) do |t|
    t.stats_options = ['--list-undoc']
    t.files = DOC_FILES
  end

  YARD::Rake::YardocTask.new(:pages) do |t|
    t.files   = DOC_FILES
    t.options = ['-o', DOC_PATH]
  end

  namespace :pages do
    task :clean do
      Dir.chdir(DOC_DIR) do
        next unless File.directory?('.git')
        sh 'git rm -rf . || echo $?' if system("git diff HEAD^..HEAD &>/dev/null | cat")
      end
    end

    desc 'Check out gh-pages.'
    task :checkout do
      unless Dir.exist?(DOC_DIR)
        Dir.mkdir(DOC_DIR)
        Dir.chdir(DOC_DIR) do
          sh 'git init'
          sh "git remote add #{DOC_REMOTE_NAME} #{DOC_REMOTE}"
          sh "git fetch #{DOC_REMOTE_NAME}"
          if system('git branch -r gh-pages')
            sh "cat .git/HEAD | grep -q 'gh-pages' || git checkout gh-pages || echo $?"
            sh "git reset --hard #{DOC_REMOTE_NAME}/#{gh-pages}"
          else
            sh 'git checkout --orphan gh-pages'
            sh 'git rm -rf . || echo $?'
            sh 'echo "Page" > index.html'
            sh 'git add index.html'
            sh 'git commit -a -m "First pages commit"'
            sh "git push #{DOC_REMOTE_NAME} gh-pages --force-with-lease"
          end
        end
      end
    end

    desc 'Generate and publish YARD docs to GitHub pages.'
    task publish: ['doc:pages:checkout', 'doc:pages:clean', 'doc:pages'] do
      Dir.chdir(DOC_DIR) do
        sh "cat .git/HEAD | grep -q 'gh-pages' || git checkout gh-pages || echo $?"
        sh 'git add .'
        sh 'git add -u'
        sh 'git diff --stat | cat'
        sh 'git diff --stat --staged | cat'
        sh 'git remote -v'
        sh "git commit -m 'Generating docs for version #{DOC_VERSION} at ref #{DOC_REF}.' && git push #{DOC_REMOTE_NAME} gh-pages --force-with-lease || echo $!"
      end
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
task ci: [:default]
