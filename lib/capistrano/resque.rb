
if Object.const_defined? :Capistrano then

  namespace :resque do
    %w(start stop restart).each do |action|
      desc "#{action.capitalize} the resque worker cluster"
      task action.to_sym do
        run "#{sudo} god restart resque-bixby"
      end
    end
  end

end
