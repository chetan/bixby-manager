
  namespace :deploy do
    desc "Update the deploy branch"
    task :update_deploy_branch do
      run_locally do
        stage = fetch(:stage)
        rev   = fetch(:current_revision)
        cmds = ["git checkout -q deploy-#{stage}",
                "git merge -q --ff-only #{rev.nil? ? rev : '<REV>'}",
                "git checkout master"]

        if rev.nil? or rev.empty? then
          cmds.each do |cmd|
            info("[deploy:update_deploy_branch] Command: #{cmd}")
          end
        else
          cmds.each do |cmd|
            execute(cmd)
          end
        end

      end
    end
  end

  after 'deploy:finished', 'deploy:update_deploy_branch'
