
if Object.const_defined? :Capistrano then

  namespace :bixby do
    %w(start stop restart).each do |action|
      desc "#{action.capitalize} the Bixby services"
      task action.to_sym do
        run "#{sudo} /etc/init.d/bixby-server god load /var/www/bixby/current/config/deploy/god/rvm.god"
        run "#{sudo} /etc/init.d/bixby-server god #{action} bixby"
      end
    end
  end

end
