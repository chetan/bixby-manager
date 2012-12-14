
if Object.const_defined? :Capistrano then

  namespace :sidekiq do
    %w(start stop restart).each do |action|
      desc "#{action.capitalize} the sidekiq worker cluster"
      task action.to_sym do
        run "#{sudo} god restart sidekiq-bixby"
      end
    end
  end

end
