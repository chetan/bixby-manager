
if Object.const_defined? :Capistrano then

  # deploy:start/stop/restart -> thin & resque start/stop/restart
  namespace :deploy do
    %w(start stop restart).each do |action|
       desc "#{action.capitalize} the application"
       task action.to_sym do
         find_and_execute_task("unicorn:#{action}")
         find_and_execute_task("sidekiq:#{action}")
      end
    end
  end

end
