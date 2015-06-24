lock '3.4.0'

set :application, 'bixby'

set :scm, :git
set :repo_url, 'https://github.com/chetan/bixby-manager.git'
set :branch, fetch(:branch, :master)
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :default_stage, "staging"
set :deploy_to, "/var/www/#{fetch(:application)}"
set :deploy_via, :remote_cache
set :bundle_without, [:development, :test]
set :rails_env, "production"

set :format, :pretty
set :log_level, :debug
# set :pty, true

set :linked_files, fetch(:linked_files, []).push(
      'config/database.yml', 'config/secrets.yml', 'config/bixby.yml')

set :linked_dirs, fetch(:linked_dirs, []).push(
      'log', 'tmp/pids', 'tmp/cache',  'vendor/bundle',
      'public/system', 'public/assets')


# cleanup on every deploy
set :keep_releases, 5
after "deploy:restart", "deploy:cleanup"

# always run migrations
set :conditionally_migrate, false
# after 'deploy:update_code', 'deploy:migrate'

after "deploy:assets:precompile", "sidekiq:link_sidekiq_assets"
after "deploy:published", "bixby:restart"

# namespace :deploy do

#   after :restart, :clear_cache do
#     on roles(:web), in: :groups, limit: 3, wait: 10 do
#       # Here we can do anything such as:
#       # within release_path do
#       #   execute :rake, 'cache:clear'
#       # end
#     end
#   end

# end
