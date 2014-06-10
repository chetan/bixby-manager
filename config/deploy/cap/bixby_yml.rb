
Capistrano::Configuration.instance.load do

  namespace :deploy do

    namespace :config do

      desc "[internal] Creates a symlink to the shared bixby.yml in the just deployed release"
      task :bixby_symlink, :except => { :no_release => true } do
        run "ln -nfs #{shared_path}/config/bixby.yml #{release_path}/config/bixby.yml"
      end

    end

    after "deploy:finalize_update", "deploy:config:bixby_symlink"

  end

end
