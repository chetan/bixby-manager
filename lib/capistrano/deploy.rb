
if Object.const_defined? :Capistrano then

  # deploy:start/stop/restart -> bixby start/stop/restart (puma & sidekiq)
  namespace :deploy do
    %w(start stop restart).each do |action|
       desc "#{action.capitalize} the application"
       task action.to_sym do
         find_and_execute_task("bixby:#{action}")
      end
    end
  end

end
