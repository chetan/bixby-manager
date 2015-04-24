
namespace :sidekiq do
  %w(start stop restart).each do |action|
    desc "#{action.capitalize} the sidekiq worker cluster"
    task action.to_sym do
      on roles(:web) do |host|
        execute :sudo, "/etc/init.d/bixby-server god restart sidekiq"
      end
    end
  end

  desc "Install symlink for properly serving assets for sidekiq-web"
  task :link_sidekiq_assets do
    on roles(:web) do |host|
      within release_path.to_s do
        bundle_path = capture("bundle", "show sidekiq")
        bundle_path = "#{bundle_path.strip}/web/assets"
        execute "ln", "-nfs #{bundle_path} public/sidekiq"
      end
    end
  end
end
