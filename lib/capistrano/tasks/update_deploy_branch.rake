
  # after 'deploy:create_symlink', 'deploy:update_deploy_branch'

  namespace :deploy do
    desc "Update the deploy branch"
    task :update_deploy_branch do
      run_locally do
        system("git checkout -q deploy-#{stage} && git merge -q --ff-only master && git checkout master")
      end
    end
  end
