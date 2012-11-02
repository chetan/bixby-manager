
load 'deploy'
load 'deploy/assets'

# config extensions
require File.join(File.expand_path(File.dirname(__FILE__)), 'config/deploy/capistrano_db_yml.rb')
require File.join(File.expand_path(File.dirname(__FILE__)), 'config/deploy/bixby_yml.rb')

# bundler
require "bundler/capistrano"
set :bundle_without, [:development, :test]

# rvm
set :rvm_ruby_string, 'ruby-1.9.3-p286'
require "rvm/capistrano"

set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "bixby"

set :scm, :git
set :repository, "https://github.com/chetan/bixby-manager.git"

set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
set :rails_env, 'production'

task :uname do
  run "uname -a"
end

namespace :deploy do

  desc "Start the Thin processes"
  task :start do
    run  <<-CMD
      cd /var/www/apps/current; bundle exec thin start -C config/thin.yml
    CMD
  end

  desc "Stop the Thin processes"
  task :stop do
    run <<-CMD
      cd /var/www/apps/current; bundle exec thin stop -C config/thin.yml
    CMD
  end

  desc "Restart the Thin processes"
  task :restart do
    run <<-CMD
      cd /var/www/apps/current; bundle exec thin restart -C config/thin.yml
    CMD
  end

end
