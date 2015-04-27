
# override deploy:assets:precompile task to add RAILS_GROUPS=assets env var

namespace :deploy do
  namespace :assets do

    Rake::Task["deploy:assets:precompile"].clear_actions
    task :precompile do
      on release_roles(fetch(:assets_roles)) do
        within release_path do
          with rails_env: fetch(:rails_env), rails_groups: "assets" do
            execute :rake, "assets:precompile"
          end
        end
      end
    end

  end
end
