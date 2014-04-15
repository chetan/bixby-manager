
if Object.const_defined? :Capistrano then

  namespace :sidekiq do
    %w(start stop restart).each do |action|
      desc "#{action.capitalize} the sidekiq worker cluster"
      task action.to_sym do
        run "#{sudo} god restart sidekiq"
      end
    end

    desc "Install symlink for properly serving assets for sidekiq-web"
    task :link_sidekiq_assets, :roles => :web do
      bundle_path = capture "cd #{latest_release}; bundle show sidekiq"
      bundle_path = "#{bundle_path.strip}/web/assets"
      run "ln -nfs #{bundle_path} #{latest_release}/public/sidekiq"
    end
  end

end
