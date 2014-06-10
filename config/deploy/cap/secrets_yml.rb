
Capistrano::Configuration.instance.load do

  namespace :deploy do

    namespace :config do

      desc "[internal] Creates a symlink to the shared secrets.yml in the just deployed release"
      task :secrets_symlink, :except => { :no_release => true } do
        run "ln -nfs #{shared_path}/config/secrets.yml #{release_path}/config/secrets.yml"
      end

    end

    after "deploy:finalize_update", "deploy:config:secrets_symlink"

  end

end
