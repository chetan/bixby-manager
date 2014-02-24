
load 'deploy'
load 'deploy/assets'

RAILS_ROOT = File.expand_path(File.dirname(__FILE__))

# config extensions
require File.join(RAILS_ROOT, 'config/deploy/cap/capistrano_db_yml.rb')
require File.join(RAILS_ROOT, 'config/deploy/cap/bixby_yml.rb')

# setup bundler
require "bundler/capistrano"
set :bundle_without, [:development, :test]

# should be set in stage config as follows:
# set :bundle_dir, "/var/www/bixby/shared/gems/#{rvm_ruby_string}"

# use rvm
require "rvm/capistrano"

# multistage
set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

# basic config
set :application, "bixby"

set :scm, :git
set :repository, "https://github.com/chetan/bixby-manager.git"

set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
set :rails_env, 'production'

# load custom tasks
%w(rake uname sidekiq puma deploy bixby update_deploy_branch).each do |t|
  load File.join(RAILS_ROOT, "lib/capistrano/#{t}.rb")
end
