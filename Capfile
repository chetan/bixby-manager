
load 'deploy'
load 'deploy/assets'

RAILS_ROOT = File.expand_path(File.dirname(__FILE__))

# config extensions
require File.join(RAILS_ROOT, 'config/deploy/capistrano_db_yml.rb')
require File.join(RAILS_ROOT, 'config/deploy/bixby_yml.rb')

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

# custom tasks
%w(uname thin).each do |t|
  load File.join(RAILS_ROOT, "lib/capistrano/#{t}.rb")
end
