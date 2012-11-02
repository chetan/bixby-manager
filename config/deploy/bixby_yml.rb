
Capistrano::Configuration.instance.load do

  namespace :deploy do

    namespace :config do

      desc <<-DESC
        [internal] Updates the symlink for bixby.yml file to the just deployed release.
      DESC
      task :symlink, :except => { :no_release => true } do
        run "ln -nfs #{shared_path}/config/bixby.yml #{release_path}/config/bixby.yml"
      end

    end

    after "deploy:finalize_update", "deploy:config:symlink"

  end

end
