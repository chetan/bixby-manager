
if Object.const_defined? :Capistrano then

  namespace :thin do
    %w(start stop restart).each do |action|
      desc "#{action.capitalize} the Thin cluster"
      task action.to_sym do
        extra = (action == "restart" ? "-O -w 10" : "") # restart one-by-one with 10 sec wait
        run  <<-CMD
          cd /var/www/bixby/current; bundle exec thin #{action} #{extra} -C config/deploy/thin.yml
        CMD
      end
    end
  end

  # "symlink" deploy:start/stop/restart to thin:start/stop/restart
  namespace :deploy do
    %w(start stop restart).each do |action|
       desc "#{action.capitalize} the Thin cluster"
       task action.to_sym do
         find_and_execute_task("thin:#{action}")
      end
    end
  end

end
